"""
API endpoints for seeding the database with test data.
"""

import json
from typing import Any, Dict, List

from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File, status
from sqlalchemy.orm import Session

from app import models, schemas
from app.api import deps
from app.utils.seed_data import create_seed_data, process_seed_file

router = APIRouter()


@router.post("/", response_model=Dict[str, Any], status_code=201)
def seed_database(
    *,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_superuser),
    num_items: int = Query(10, ge=1, le=100, description="Number of random items to create"),
    num_notes: int = Query(10, ge=1, le=100, description="Number of random notes to create")
) -> Dict[str, Any]:
    """
    Seed the database with random test data.
    
    This endpoint generates random items and notes with realistic data.
    All created data will be owned by the authenticated user.
    
    ## Permissions
    * Requires superuser privileges
    
    ## Parameters
    * **num_items**: Number of random items to create (default: 10, max: 100)
    * **num_notes**: Number of random notes to create (default: 10, max: 100)
    
    ## Returns
    * **items_created**: Total number of items created
    * **notes_created**: Total number of notes created
    * **items**: List of created items with their IDs and titles
    * **notes**: List of created notes with their IDs and titles
    
    ## Example Response
    ```json
    {
      "items_created": 2,
      "notes_created": 2,
      "items": [
        {"id": 2, "title": "Database Solution 8622"},
        {"id": 3, "title": "IoT Platform 1831"}
      ],
      "notes": [
        {"id": 2, "title": "Implementation Strategy 6917"},
        {"id": 3, "title": "Development Roadmap 8235"}
      ]
    }
    ```
    """
    result = create_seed_data(
        db=db,
        user_id=current_user.id,
        num_items=num_items,
        num_notes=num_notes
    )
    
    return result


@router.post("/upload", response_model=Dict[str, Any], status_code=201)
async def seed_from_file(
    *,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_superuser),
    file: UploadFile = File(...),
) -> Dict[str, Any]:
    """
    Seed the database with data from an uploaded JSON file.
    
    This endpoint allows you to upload a JSON file containing predefined items and notes.
    All created data will be owned by the authenticated user.
    
    ## Permissions
    * Requires superuser privileges
    
    ## Request Body
    * **file**: A JSON file containing items and notes to create
    
    ## File Format
    The uploaded JSON file should have the following structure:
    ```json
    {
      "items": [
        {
          "title": "Item Title 1",
          "description": "Description of item 1",
          "is_active": true
        }
      ],
      "notes": [
        {
          "title": "Note Title 1",
          "content": "Content of note 1"
        }
      ]
    }
    ```
    
    ## Returns
    * **items_created**: Total number of items created
    * **notes_created**: Total number of notes created
    * **items**: List of created items with their IDs and titles
    * **notes**: List of created notes with their IDs and titles
    
    ## Example Response
    ```json
    {
      "items_created": 2,
      "notes_created": 2,
      "items": [
        {"id": 5, "title": "Custom Item 1"},
        {"id": 6, "title": "Custom Item 2"}
      ],
      "notes": [
        {"id": 4, "title": "Custom Note 1"},
        {"id": 5, "title": "Custom Note 2"}
      ]
    }
    ```
    """
    # Validate file extension
    if not file.filename.endswith('.json'):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only JSON files are supported"
        )
    
    try:
        # Read and parse the file
        contents = await file.read()
        seed_data = json.loads(contents)
        
        # Process the seed data
        result = process_seed_file(
            db=db,
            user_id=current_user.id,
            seed_data=seed_data
        )
        
        return result
    except json.JSONDecodeError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid JSON format in the uploaded file"
        )
    except KeyError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Missing required key in seed data: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error processing seed data: {str(e)}"
        ) 