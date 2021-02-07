from datetime import timedelta,datetime
from django.utils import timezone
from django.db import models
from django.utils.translation import gettext_lazy as _
from django.contrib.auth.models import User
from tracks.models import Track

def round_timedelta(delta):
    delta += timedelta(microseconds = 500000)
    if isinstance(delta, datetime):
        delta -= timedelta(microseconds = delta.microsecond)
    elif isinstance(delta, timedelta):
        delta -= timedelta(microseconds = delta.microseconds)

    return delta

class ProcessingStatus(models.Model):
    name = models.CharField(max_length=20)
    toProcess = models.IntegerField(null=True)
    nProcessed = models.IntegerField(default=0)
    start_time = models.DateTimeField('date and time of start of operation',default=timezone.now)
    last_update = models.DateTimeField('date and time of last update',default=timezone.now)
    end_time = models.DateTimeField('date and time of end of operation',null=True)
    track = models.ForeignKey(Track, on_delete=models.CASCADE)
#    resume = models.CharField('json serialization of parameters necessary to pick up interrupted processing',max_length=64)

    def setProgress(self, nProcessed=None):
        self.last_update = timezone.now()
        if nProcessed is not None:
            self.nProcessed = nProcessed
        self.save()

    def incProgress(self, nProcessed):
        self.setProgress(self.nProcessed + nProcessed)

    def end(self):
        self.last_update = timezone.now()
        self.end_time    = self.last_update
        self.save()

    def percent_done(self):
        if self.toProcess is not None and self.toProcess > 0:
            return 100. * min(self.nProcessed,self.toProcess) / self.toProcess

    def time_left(self):
        p = self.percent_done()
        if p is not None:
            if p >= 100:
                td = timedelta(seconds=0)
            else:
                td = (timezone.now() - self.start_time) * (100-p)/p
            return round_timedelta(td)

    def ETA(self):
        tl = self.time_left()
        if tl is not None:
            return round_timedelta(timezone.now() + tl)

    def __str__(self):
        tl = self.time_left()
        if tl is not None:

            p = self.percent_done()
            assert p is not None
            status = '%2.2f%%'%(p)
            if tl > timedelta(seconds=0):
                status += ' %s'%(tl)
            status += ' (ETA %s) '%(timezone.localtime(self.ETA()))
        else:
            td = round_timedelta(self.last_update-self.start_time)

            status = 'processed=%d'%self.nProcessed
            if td.total_seconds() > 0:
                status += '(%1.0f / min)'%(self.nProcessed * 60 / td.total_seconds())

        if self.end_time is None:
            last_update = '({})'.format(timezone.localtime(round_timedelta(self.last_update)))
        else:
            last_update = '(ended {})'.format(timezone.localtime(round_timedelta(self.end_time)))

        return '{} #{}: {} {}'.format(self.name, self.track_id, status, last_update)

    class Meta:
        ordering = ['-last_update']
        verbose_name_plural = 'processing statuses'
