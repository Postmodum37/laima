import unittest

import tallyfile


class CountWords(unittest.TestCase):
    def test_counts_case_insensitively(self):
        self.assertEqual(tallyfile.count_words("The the THE cat")["the"], 3)

    def test_empty_text(self):
        self.assertEqual(len(tallyfile.count_words("")), 0)


if __name__ == "__main__":
    unittest.main()
