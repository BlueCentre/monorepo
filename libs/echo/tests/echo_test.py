import unittest

from libs.echo.models.echo import Echo

class TestEcho(unittest.TestCase):
  def test_message_with_argument(self):
    my_echo = Echo("hello")
    self.assertEqual(my_echo.__str__(), "hello")

  def test_message_with_argument_unexpected(self):
    my_echo = Echo("hello")
    self.assertNotEqual(my_echo.__str__(), "world")

  def test_message_without_argument(self):
    my_echo = Echo()
    self.assertEqual(my_echo.__str__(), "No message was passed")

if __name__ == '__main__':
  unittest.main()
