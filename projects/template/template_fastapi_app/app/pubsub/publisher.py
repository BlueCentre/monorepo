"""
Google Cloud Pub/Sub publisher service.
"""

import json
import logging
from typing import Any, Dict, Optional

from google.cloud import pubsub_v1
from google.api_core.exceptions import AlreadyExists

from app.core.config import settings

logger = logging.getLogger(__name__)


class PubSubPublisher:
    """Google Cloud Pub/Sub publisher service."""
    
    def __init__(self):
        """Initialize the publisher client."""
        self.project_id = settings.GCP_PROJECT_ID
        
        # Skip initialization if project ID is not set
        if not self.project_id:
            logger.warning("GCP_PROJECT_ID is not set. PubSub publisher will not be initialized.")
            self.publisher = None
            return
            
        self.publisher = pubsub_v1.PublisherClient()
        
        # Create topics if they don't exist
        try:
            self._ensure_topic_exists(settings.PUBSUB_TOPIC_EXAMPLE)
        except Exception as e:
            logger.error(f"Failed to ensure topic exists: {e}")
    
    def _ensure_topic_exists(self, topic_name: str) -> None:
        """
        Ensure that a topic exists, creating it if it doesn't.
        
        Args:
            topic_name: Name of the topic.
        """
        if not self.publisher:
            return
            
        topic_path = self.publisher.topic_path(self.project_id, topic_name)
        
        try:
            self.publisher.create_topic(request={"name": topic_path})
            logger.info(f"Created topic: {topic_path}")
        except AlreadyExists:
            logger.info(f"Topic already exists: {topic_path}")
    
    def publish_message(
        self, 
        topic_name: str, 
        message: Dict[str, Any], 
        attributes: Optional[Dict[str, str]] = None
    ) -> str:
        """
        Publish a message to a topic.
        
        Args:
            topic_name: Name of the topic.
            message: Message to publish.
            attributes: Optional attributes to include with the message.
            
        Returns:
            str: Message ID.
        """
        if not self.publisher:
            logger.warning("PubSub publisher is not initialized. Message will not be published.")
            return "not-published"
            
        topic_path = self.publisher.topic_path(self.project_id, topic_name)
        
        # Convert message to JSON string
        message_json = json.dumps(message).encode("utf-8")
        
        # Publish message
        future = self.publisher.publish(
            topic_path, 
            data=message_json,
            **attributes if attributes else {}
        )
        
        # Get message ID
        message_id = future.result()
        logger.info(f"Published message with ID: {message_id}")
        
        return message_id


# Create a singleton instance
pubsub_publisher = PubSubPublisher() 