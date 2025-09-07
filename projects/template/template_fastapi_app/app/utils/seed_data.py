"""
Utilities for generating seed data for testing and development.

This module provides functions to generate realistic random test data for the application.
It can create items and notes with varied content and is useful for development,
testing, and demonstration purposes.

Usage example:
    from app.utils.seed_data import create_seed_data

    # Create 10 items and 5 notes owned by user with ID 1
    result = create_seed_data(db_session, user_id=1, num_items=10, num_notes=5)
"""

import logging
import random
from typing import Any

from sqlalchemy.orm import Session

from app import crud, schemas

logger = logging.getLogger(__name__)

# Sample data for generating random content
ITEM_TITLES = [
    "Productivity Tool",
    "Development Framework",
    "Cloud Service",
    "Machine Learning Library",
    "Mobile Application",
    "Data Visualization Tool",
    "Database Solution",
    "API Service",
    "Security Software",
    "IoT Platform",
]

NOTE_TITLES = [
    "Meeting Notes",
    "Project Ideas",
    "API Documentation",
    "Design Patterns",
    "Research Findings",
    "Implementation Strategy",
    "User Feedback",
    "Performance Metrics",
    "Team Updates",
    "Development Roadmap",
]

ADJECTIVES = [
    "innovative",
    "powerful",
    "efficient",
    "scalable",
    "robust",
    "intuitive",
    "seamless",
    "secure",
    "flexible",
    "advanced",
]


def generate_random_description(base_name: str) -> str:
    """
    Generate a random description based on a base name.

    Args:
        base_name: The base name to include in the description

    Returns:
        A randomly generated description string

    Example:
        >>> generate_random_description("Cloud Service")
        "This Cloud Service is an innovative and scalable solution designed for modern applications."
    """
    adj1 = random.choice(ADJECTIVES)
    adj2 = random.choice(ADJECTIVES)
    while adj1 == adj2:  # Ensure different adjectives
        adj2 = random.choice(ADJECTIVES)

    return f"This {base_name} is an {adj1} and {adj2} solution designed for modern applications."


def generate_random_content(base_name: str) -> str:
    """
    Generate random content for notes based on a base name.

    Args:
        base_name: The base name to include in the content

    Returns:
        A randomly generated multi-sentence content string

    Example:
        >>> generate_random_content("API Documentation")
        "Important information about API Documentation. We need to review the API Documentation implementation."
    """
    sentences = [
        f"Important information about {base_name}.",
        f"We need to review the {base_name} implementation.",
        f"Key considerations for {base_name} development include scalability and security.",
        f"Future improvements for {base_name} might include enhanced performance metrics.",
        f"Team feedback on {base_name} has been largely positive.",
    ]

    # Select a random number of sentences (2-5)
    num_sentences = random.randint(2, 5)
    selected_sentences = random.sample(sentences, num_sentences)

    return " ".join(selected_sentences)


def create_seed_data(
    db: Session, user_id: int, num_items: int = 10, num_notes: int = 10
) -> dict[str, Any]:
    """
    Create seed data in the database.

    This function generates and stores random items and notes in the database.
    All created data is associated with the specified user ID.

    Args:
        db: Database session
        user_id: ID of the user who will own the seed data
        num_items: Number of random items to create (default: 10)
        num_notes: Number of random notes to create (default: 10)

    Returns:
        Dict containing summary of created data with keys:
        - items_created: number of items created
        - notes_created: number of notes created
        - items: list of created items with id and title
        - notes: list of created notes with id and title

    Example:
        >>> result = create_seed_data(db_session, user_id=1, num_items=5, num_notes=3)
        >>> print(f"Created {result['items_created']} items and {result['notes_created']} notes")
        Created 5 items and 3 notes
    """
    created_items = []
    created_notes = []

    # Create random items
    for _ in range(num_items):
        title = f"{random.choice(ITEM_TITLES)} {random.randint(1000, 9999)}"
        description = generate_random_description(title)

        item_in = schemas.ItemCreate(
            title=title, description=description, is_active=True
        )

        try:
            item = crud.item.create_with_owner(db, obj_in=item_in, owner_id=user_id)
            created_items.append({"id": item.id, "title": item.title})
            logger.info(f"Created seed item: {item.title}")
        except Exception as e:
            logger.error(f"Error creating seed item: {e}")

    # Create random notes
    for _ in range(num_notes):
        title = f"{random.choice(NOTE_TITLES)} {random.randint(1000, 9999)}"
        content = generate_random_content(title)

        note_in = schemas.NoteCreate(title=title, content=content)

        try:
            note = crud.note.create_with_owner(db, obj_in=note_in, owner_id=user_id)
            created_notes.append({"id": note.id, "title": note.title})
            logger.info(f"Created seed note: {note.title}")
        except Exception as e:
            logger.error(f"Error creating seed note: {e}")

    return {
        "items_created": len(created_items),
        "notes_created": len(created_notes),
        "items": created_items,
        "notes": created_notes,
    }


def process_seed_file(
    db: Session, user_id: int, seed_data: dict[str, Any]
) -> dict[str, Any]:
    """
    Process a seed data file and create items and notes from it.

    Args:
        db: Database session
        user_id: ID of the user who will own the seed data
        seed_data: Dictionary containing items and notes to create

    Returns:
        Dict containing summary of created data with keys:
        - items_created: number of items created
        - notes_created: number of notes created
        - items: list of created items with id and title
        - notes: list of created notes with id and title

    Raises:
        KeyError: If the seed data is missing required keys
        ValueError: If the seed data has invalid values

    Example:
        >>> seed_data = {
        ...     "items": [
        ...         {"title": "Item 1", "description": "Description 1"},
        ...         {"title": "Item 2", "description": "Description 2"}
        ...     ],
        ...     "notes": [
        ...         {"title": "Note 1", "content": "Content 1"},
        ...         {"title": "Note 2", "content": "Content 2"}
        ...     ]
        ... }
        >>> result = process_seed_file(db_session, user_id=1, seed_data=seed_data)
        >>> print(f"Created {result['items_created']} items and {result['notes_created']} notes")
        Created 2 items and 2 notes
    """
    if "items" not in seed_data and "notes" not in seed_data:
        raise KeyError("Seed data must contain 'items' or 'notes' array")

    created_items = []
    created_notes = []

    # Process items
    if "items" in seed_data and isinstance(seed_data["items"], list):
        for item_data in seed_data["items"]:
            if not isinstance(item_data, dict):
                logger.warning(f"Skipping invalid item data: {item_data}")
                continue

            # Ensure required fields exist
            if "title" not in item_data:
                logger.warning(f"Skipping item without title: {item_data}")
                continue

            # Set default values for optional fields
            if "description" not in item_data:
                item_data["description"] = f"Description for {item_data['title']}"
            if "is_active" not in item_data:
                item_data["is_active"] = True

            try:
                item_in = schemas.ItemCreate(**item_data)
                item = crud.item.create_with_owner(db, obj_in=item_in, owner_id=user_id)
                created_items.append({"id": item.id, "title": item.title})
                logger.info(f"Created seed item from file: {item.title}")
            except Exception as e:
                logger.error(f"Error creating seed item from file: {e}")

    # Process notes
    if "notes" in seed_data and isinstance(seed_data["notes"], list):
        for note_data in seed_data["notes"]:
            if not isinstance(note_data, dict):
                logger.warning(f"Skipping invalid note data: {note_data}")
                continue

            # Ensure required fields exist
            if "title" not in note_data:
                logger.warning(f"Skipping note without title: {note_data}")
                continue

            # Set default values for optional fields
            if "content" not in note_data:
                note_data["content"] = f"Content for {note_data['title']}"

            try:
                note_in = schemas.NoteCreate(**note_data)
                note = crud.note.create_with_owner(db, obj_in=note_in, owner_id=user_id)
                created_notes.append({"id": note.id, "title": note.title})
                logger.info(f"Created seed note from file: {note.title}")
            except Exception as e:
                logger.error(f"Error creating seed note from file: {e}")

    return {
        "items_created": len(created_items),
        "notes_created": len(created_notes),
        "items": created_items,
        "notes": created_notes,
    }
