"""
Google Cloud Pub/Sub subscriber service.
"""

import json
import logging
from typing import Any, Callable, Dict, Optional

from google.cloud import pubsub_v1
from google.api_core.exceptions import AlreadyExists, NotFound

from app.core.config import settings

logger = logging.getLogger(__name__)


class PubSubSubscriber:
    """Google Cloud Pub/Sub subscriber service."""
    
    def __init__(self):
        """Initialize the subscriber client."""
        self.project_id = settings.GCP_PROJECT_ID
        
        # Skip initialization if project ID is not set
        if not self.project_id:
            logger.warning("GCP_PROJECT_ID is not set. PubSub subscriber will not be initialized.")
            self.subscriber = None
            return
            
        self.subscriber = pubsub_v1.SubscriberClient()
        
        # Create subscriptions if they don't exist
        try:
            self._ensure_subscription_exists(
                settings.PUBSUB_TOPIC_EXAMPLE,
                settings.PUBSUB_SUBSCRIPTION_EXAMPLE
            )
        except Exception as e:
            logger.error(f"Failed to ensure subscription exists: {e}")
    
    def _ensure_subscription_exists(self, topic_name: str, subscription_name: str) -> None:
        """
        Ensure that a subscription exists, creating it if it doesn't.
        
        Args:
            topic_name: Name of the topic.
            subscription_name: Name of the subscription.
        """
        if not self.subscriber:
            return
            
        topic_path = self.subscriber.topic_path(self.project_id, topic_name)
        subscription_path = self.subscriber.subscription_path(self.project_id, subscription_name)
        
        try:
            self.subscriber.create_subscription(
                request={"name": subscription_path, "topic": topic_path}
            )
            logger.info(f"Created subscription: {subscription_path}")
        except AlreadyExists:
            logger.info(f"Subscription already exists: {subscription_path}")
        except NotFound:
            logger.error(f"Topic not found: {topic_path}")
    
    def subscribe(
        self, 
        subscription_name: str, 
        callback: Callable[[Dict[str, Any], Dict[str, str]], None]
    ) -> Optional[pubsub_v1.subscriber.futures.StreamingPullFuture]:
        """
        Subscribe to a subscription and process messages.
        
        Args:
            subscription_name: Name of the subscription.
            callback: Callback function to process messages.
            
        Returns:
            StreamingPullFuture: Future for the subscription, or None if subscriber is not initialized.
        """
        if not self.subscriber:
            logger.warning("PubSub subscriber is not initialized. Cannot subscribe.")
            return None
            
        subscription_path = self.subscriber.subscription_path(self.project_id, subscription_name)
        
        def process_message(message: pubsub_v1.subscriber.message.Message) -> None:
            """
            Process a Pub/Sub message.
            
            Args:
                message: Pub/Sub message.
            """
            logger.info(f"Received message: {message.message_id}")
            
            try:
                # Parse message data
                data = json.loads(message.data.decode("utf-8"))
                
                # Call callback with data and attributes
                callback(data, dict(message.attributes))
                
                # Acknowledge message
                message.ack()
                
                logger.info(f"Processed message: {message.message_id}")
            except Exception as e:
                logger.error(f"Error processing message {message.message_id}: {str(e)}")
                message.nack()
        
        # Subscribe to the subscription
        future = self.subscriber.subscribe(subscription_path, process_message)
        logger.info(f"Subscribed to {subscription_path}")
        
        return future


# Create a singleton instance
pubsub_subscriber = PubSubSubscriber() 