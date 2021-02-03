from rest_framework import permissions

class IsSubmitter(permissions.BasePermission):
  """
  Custom permission to only allow owners of an object to view or change it.
  """

  def has_object_permission(self, request, view, obj):
    # staff can do and view everything
    if request.user.is_staff:
      return True

    # If non-staff, only the submitter is able to view, or change
    return obj.submitter == request.user
