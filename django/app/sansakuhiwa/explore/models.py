from django.db import models

# Create your models here
class Spot(models.Model):
    name = models.CharField(max_length=20, verbose_name="史跡名")
    lat = models.FloatField(verbose_name="緯度")
    lng = models.FloatField(verbose_name="経度")
    description = models.TextField(verbose_name="場所の説明")
    relation = models.CharField(max_length=20, verbose_name="関連人物名")

    def __str__(self):
        return self.name
    
    class Meta:
        verbose_name = ('史跡')