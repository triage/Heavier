import unittest
import pytest
from unittest.mock import patch, MagicMock
from firebase_functions import https_fn
from unittest.mock import patch, MagicMock
from functions.exercise_resolve_name import exercise_resolve_name

class TestExerciseResolveName(unittest.TestCase):

    @patch('vocabulary.exercise_resolve_name')
    def test_exercise_resolve_name_valid_query(self, mock_resolve_name):
        mock_resolve_name.return_value = "exercise1"
        req = MagicMock()
        req.data = {"query": "exercise"}
        result = exercise_resolve_name(req)
        assert result == "exercise1"
        mock_resolve_name.assert_called_once_with("exercis")

    @patch('vocabulary.exercise_resolve_name')
    def test_exercise_resolve_name_no_match(self, mock_resolve_name):
        mock_resolve_name.return_value = None
        req = MagicMock()
        req.data = {"query": "unknown"}
        result = exercise_resolve_name(req)
        assert result is None
        mock_resolve_name.assert_called_once_with("unknown")

    @patch('vocabulary.exercise_resolve_name')
    def test_exercise_resolve_name_missing_query(self, mock_resolve_name):
        req = MagicMock()
        req.data = {}
        result = exercise_resolve_name(req)
        assert result is None
        mock_resolve_name.assert_not_called()

if __name__ == '__main__':
    unittest.main()

