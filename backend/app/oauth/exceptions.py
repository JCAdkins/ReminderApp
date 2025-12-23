class AuthError(Exception):
    """Base class for authentication-related errors."""
    pass


class OAuthOnlyAccount(AuthError):
    """Raised when a user attempts password login on an OAuth-only account."""
    def __init__(self, provider: str | None = None):
        self.provider = provider
