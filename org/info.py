from django.http.response import HttpResponse

import subprocess


def info(request):

    out = "Version Info <br><br>"

    process = subprocess.Popen(['git', 'rev-parse', 'HEAD'], shell=False, stdout=subprocess.PIPE)
    git_head_hash = process.communicate()[0].strip()
    out += "commit id<br>{}".format(git_head_hash.decode('utf8'))

    process = subprocess.Popen(['git', 'remote', '-v'], shell=False, stdout=subprocess.PIPE)
    git_status = process.communicate()[0].strip().decode('utf8')
    out += "<br><br>remotes<br>{}".format(git_status.replace("\n","<br>"))

    process = subprocess.Popen(['git', 'branch'], shell=False, stdout=subprocess.PIPE)
    git_branch = process.communicate()[0].strip().decode('utf8')
    out += "<br><br>branch<br>{}<br>".format(git_branch.replace("\n","<br>"))

    return HttpResponse(out)
