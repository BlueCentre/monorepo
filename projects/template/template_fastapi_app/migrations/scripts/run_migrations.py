"""
Script to run database migrations using Alembic.
"""

import logging
import sys
from alembic.config import Config
from alembic import command

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def run_migrations():
    """Run Alembic migrations."""
    logger.info("Running database migrations")
    
    # Create Alembic configuration
    alembic_config = Config("alembic.ini")
    
    # Get command line arguments
    if len(sys.argv) > 1:
        command_name = sys.argv[1]
        
        if command_name == "upgrade":
            # Default to 'head' if no revision is specified
            revision = "head" if len(sys.argv) <= 2 else sys.argv[2]
            logger.info(f"Upgrading database to revision: {revision}")
            command.upgrade(alembic_config, revision)
            
        elif command_name == "downgrade":
            # Require explicit revision for downgrades
            if len(sys.argv) <= 2:
                logger.error("Error: Revision must be specified for downgrade")
                sys.exit(1)
            revision = sys.argv[2]
            logger.info(f"Downgrading database to revision: {revision}")
            command.downgrade(alembic_config, revision)
            
        elif command_name == "revision":
            # Create a new migration
            if len(sys.argv) <= 2:
                logger.error("Error: Message must be specified for revision")
                sys.exit(1)
            message = sys.argv[2]
            autogenerate = "--autogenerate" in sys.argv
            logger.info(f"Creating a new migration with message: {message} (autogenerate: {autogenerate})")
            command.revision(alembic_config, message, autogenerate=autogenerate)
            
        elif command_name == "history":
            # Show migration history
            logger.info("Showing migration history")
            command.history(alembic_config)
            
        else:
            logger.error(f"Error: Unknown command: {command_name}")
            logger.info("Available commands: upgrade, downgrade, revision, history")
            sys.exit(1)
    else:
        # Default to upgrading to the latest version
        logger.info("No command specified, upgrading to latest version")
        command.upgrade(alembic_config, "head")
    
    logger.info("Database migration completed")

if __name__ == "__main__":
    run_migrations() 