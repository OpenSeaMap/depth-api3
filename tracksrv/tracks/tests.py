from django.test import TestCase
from django.urls import reverse

# Create your tests here.

from .models import Track

class DetailViewTests(TestCase):
    # an internal test for something
    def test_something(self):
        """
        This is a stub for now
        """
        self.assertIs(True,True)

# test the track index view
class TrackIndexViewTests(TestCase):
    def test_no_tracks(self):
        """
        If no tracks exist, an appropriate message is displayed.
        """
        response = self.client.get(reverse('tracks:index'))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "No tracks are available.")
        self.assertQuerysetEqual(response.context['tracks'], [])
