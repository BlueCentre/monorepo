class Echo:
    
    def __init__(self, message=None):
        self.message = message

    def __str__(self):
        return self.message or "No message was passed"
