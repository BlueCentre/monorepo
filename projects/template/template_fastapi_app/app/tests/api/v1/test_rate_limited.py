"""
Tests for rate-limited endpoints.
"""

from typing import Dict
import time
import pytest
from fastapi.testclient import TestClient

from app.core.config import settings
from app.tests.utils.user import authentication_token_from_email, create_random_user
from app.tests.utils.utils import random_email, random_lower_string


@pytest.fixture(scope="module")
def normal_user_token_headers(client: TestClient) -> Dict[str, str]:
    """
    Create a normal user and return the authorization headers.
    """
    return authentication_token_from_email(
        client=client, email=settings.EMAIL_TEST_USER, password=settings.PASSWORD_TEST_USER
    )


@pytest.fixture(scope="module")
def superuser_token_headers(client: TestClient) -> Dict[str, str]:
    """
    Create a superuser and return the authorization headers.
    """
    return authentication_token_from_email(
        client=client, email=settings.FIRST_SUPERUSER, password=settings.FIRST_SUPERUSER_PASSWORD
    )


@pytest.fixture(scope="module")
def second_user_token_headers(client: TestClient, db) -> Dict[str, str]:
    """
    Create a second user and return the authorization headers.
    This is used to test that rate limits are applied separately for different users.
    """
    user = create_random_user(db)
    return authentication_token_from_email(
        client=client, email=user.email, password=random_lower_string()
    )


def test_rate_limited_endpoint(client: TestClient, normal_user_token_headers: Dict[str, str]) -> None:
    """
    Test the rate-limited endpoint returns the correct response when not rate limited.
    """
    response = client.get(
        f"{settings.API_V1_STR}/rate-limited/rate-limited",
        headers=normal_user_token_headers,
    )
    assert response.status_code == 200
    data = response.json()
    assert "user_id" in data
    assert "user_email" in data
    assert "message" in data
    assert data["message"] == "Successfully accessed rate-limited endpoint"


def test_rate_limited_endpoint_rate_limit(client: TestClient, normal_user_token_headers: Dict[str, str]) -> None:
    """
    Test the rate limit on the rate-limited endpoint.
    Send 4 requests in succession. The 4th should return a 429 Too Many Requests.
    This tests that the rate limit is properly enforced.
    """
    # Send 3 requests (rate limit is 3 per minute)
    for _ in range(3):
        response = client.get(
            f"{settings.API_V1_STR}/rate-limited/rate-limited",
            headers=normal_user_token_headers,
        )
        assert response.status_code == 200
    
    # Send the 4th request, which should be rate limited
    response = client.get(
        f"{settings.API_V1_STR}/rate-limited/rate-limited",
        headers=normal_user_token_headers,
    )
    assert response.status_code == 429
    assert "detail" in response.json()


def test_rate_limited_by_user_endpoint(client: TestClient, normal_user_token_headers: Dict[str, str]) -> None:
    """
    Test the user-based rate-limited endpoint.
    """
    response = client.get(
        f"{settings.API_V1_STR}/rate-limited/rate-limited-user",
        headers=normal_user_token_headers,
    )
    assert response.status_code == 200
    data = response.json()
    assert "user_id" in data
    assert "user_email" in data
    assert "message" in data
    assert data["message"] == "Successfully accessed user-based rate-limited endpoint"


def test_unauthorized_access(client: TestClient) -> None:
    """
    Test that unauthorized access to rate-limited endpoints is denied.
    This verifies that authentication is required before rate limiting is applied.
    """
    response = client.get(
        f"{settings.API_V1_STR}/rate-limited/rate-limited",
    )
    assert response.status_code == 401
    
    response = client.get(
        f"{settings.API_V1_STR}/rate-limited/rate-limited-user",
    )
    assert response.status_code == 401


def test_different_users_separate_rate_limits(
    client: TestClient, 
    normal_user_token_headers: Dict[str, str],
    second_user_token_headers: Dict[str, str]
) -> None:
    """
    Test that different users have separate rate limits.
    First user reaches the limit, but second user should still be able to access.
    This ensures rate limits are properly scoped to individual users for user-based rate limiting.
    """
    # First user makes requests until rate limited
    for _ in range(10):
        response = client.get(
            f"{settings.API_V1_STR}/rate-limited/rate-limited-user",
            headers=normal_user_token_headers,
        )
        if response.status_code == 429:
            break
    
    # Verify first user is now rate limited
    response = client.get(
        f"{settings.API_V1_STR}/rate-limited/rate-limited-user",
        headers=normal_user_token_headers,
    )
    assert response.status_code == 429
    
    # Second user should still be able to access
    response = client.get(
        f"{settings.API_V1_STR}/rate-limited/rate-limited-user",
        headers=second_user_token_headers,
    )
    assert response.status_code == 200
    data = response.json()
    assert data["message"] == "Successfully accessed user-based rate-limited endpoint"


@pytest.mark.slow
def test_rate_limit_reset(client: TestClient, normal_user_token_headers: Dict[str, str]) -> None:
    """
    Test that rate limits reset after the specified window.
    This test is marked as slow because it needs to wait for the rate limit window to expire.
    """
    # First exhaust the rate limit
    for _ in range(3):
        client.get(
            f"{settings.API_V1_STR}/rate-limited/rate-limited",
            headers=normal_user_token_headers,
        )
    
    # Verify rate limit is reached
    response = client.get(
        f"{settings.API_V1_STR}/rate-limited/rate-limited",
        headers=normal_user_token_headers,
    )
    assert response.status_code == 429
    
    # Wait for rate limit window to expire (65 seconds to be safe)
    # Note: This might be too slow for regular testing, so it's marked with pytest.mark.slow
    # In a real environment, you might mock time or use dependency injection to control the time
    time.sleep(65)
    
    # Verify rate limit has reset
    response = client.get(
        f"{settings.API_V1_STR}/rate-limited/rate-limited",
        headers=normal_user_token_headers,
    )
    assert response.status_code == 200
    data = response.json()
    assert data["message"] == "Successfully accessed rate-limited endpoint"


def test_rate_limit_headers(client: TestClient, normal_user_token_headers: Dict[str, str]) -> None:
    """
    Test that rate limit headers are included in the response.
    This ensures that clients can track their rate limit usage.
    """
    response = client.get(
        f"{settings.API_V1_STR}/rate-limited/rate-limited",
        headers=normal_user_token_headers,
    )
    assert response.status_code == 200
    
    # Check for rate limit headers - note that the exact header names might 
    # depend on your rate limiting implementation
    assert "X-RateLimit-Limit" in response.headers or "RateLimit-Limit" in response.headers
    assert "X-RateLimit-Remaining" in response.headers or "RateLimit-Remaining" in response.headers
    
    # Once rate limited, verify Retry-After header is present
    for _ in range(5):  # Exhaust the limit
        client.get(
            f"{settings.API_V1_STR}/rate-limited/rate-limited",
            headers=normal_user_token_headers,
        )
    
    response = client.get(
        f"{settings.API_V1_STR}/rate-limited/rate-limited",
        headers=normal_user_token_headers,
    )
    assert response.status_code == 429
    assert "Retry-After" in response.headers 