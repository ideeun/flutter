from django.db import models

class Currency(models.Model):
    name = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.name