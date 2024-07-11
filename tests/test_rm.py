from rm import DuckDuckGoSearch
import unittest
from unittest.mock import patch

# This is a test class for the DuckDuckGoSearch class
class TestDuckDuckGoSearch(unittest.TestCase):
    @patch("requests.get")
    def test_get_instant_answer_valid_query(self, mock_get):
        """Test successful instant answer retrieval."""
        mock_get.return_value.status_code = 200
        mock_get.return_value.json.return_value = {
            "Abstract": "This is a test instant answer."
        }

        searcher = DuckDuckGoSearch()
        result = searcher._get_instant_answer("test query")
        self.assertEqual(result, "This is a test instant answer.")

    @patch("requests.get")
    def test_get_instant_answer_no_answer(self, mock_get):
        """Test when no instant answer is available."""
        mock_get.return_value.status_code = 200
        mock_get.return_value.json.return_value = {
            "Abstract": ""
        }

        searcher = DuckDuckGoSearch()
        result = searcher._get_instant_answer("test query")
        self.assertIsNone(result)

    @patch("requests.get")
    def test_get_instant_answer_api_error(self, mock_get):
        """Test when the API returns an error."""
        mock_get.return_value.status_code = 500

        searcher = DuckDuckGoSearch()
        result = searcher._get_instant_answer("test query")
        self.assertIsNone(result)

    @patch("requests.get")
    def test_get_search_results(self, mock_get):
        """Test retrieval of search results."""
        mock_get.return_value.status_code = 200
        mock_get.return_value.text = "<html><body><a class='result__a' href='https://www.example.com'>Test Result</a></body></html>"

        searcher = DuckDuckGoSearch()
        results = searcher._get_search_results("test query", [])
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]["title"], "Test Result")
        self.assertEqual(results[0]["url"], "https://www.example.com")

    # Add more tests for forward method, filtering, error handling, etc.

class TestDuckDuckGoSearchLive(unittest.TestCase):
    def test_get_instant_answer_valid_query_live(self):
        """Live test for successful instant answer retrieval."""
        searcher = DuckDuckGoSearch()
        result = searcher._get_instant_answer("what is the capital of France?")
        self.assertIsNotNone(result)  # Check if result is not None

    def test_get_instant_answer_no_answer_live(self):
        """Live test when no instant answer is available."""
        searcher = DuckDuckGoSearch()
        # Choose a query that is unlikely to have an instant answer
        result = searcher._get_instant_answer("what is the meaning of life according to Douglas Adams?") 
        self.assertIsNone(result)

    def test_get_search_results_live(self):
        """Live test for retrieval of search results."""
        searcher = DuckDuckGoSearch()
        results = searcher._get_search_results("python programming", [])
        self.assertGreater(len(results), 0)  # Check if at least one result is returned
        