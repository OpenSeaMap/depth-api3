from django.db import connection
import logging
logger = logging.getLogger(__name__)

class IndexManagerMixin:
  """
  A mix-in to manage (mostly, drop and re-create) indices 
  """

  @classmethod
  def index_has_field(cls,fields):
    """
    returns a list of indices that apply to any of the fields in fields
    """
    def idx_applies(i,fields):
        return any(f in i.fields for f in fields)

    return filter(lambda i:idx_applies(i,fields),cls._meta.indexes)

  @classmethod
  def drop_index(cls,fields):
    """
    idx is a list of field names. Go through the indexes of this models and drop all that include the field name
    """

    index_to_drop = cls.index_has_field(fields)
    sql = ";".join(["DROP INDEX IF EXISTS %s"%i.name for i in index_to_drop])
    logger.debug("drop_index sql: %s",sql)
    with connection.cursor() as cursor:
      cursor.execute(sql)

  @classmethod
  def create_index(cls,fields):
    """
    idx is a list of field names. Go through the indexes of this models and create all that include the field name
    """

    index_to_create = cls.index_has_field(fields)
    tablename = cls._meta.db_table

    sql = ";".join(["CREATE INDEX %s ON %s (%s%s)"%(i.name,tablename,",".join(i.fields)," ("+",".join(i.opclasses)+")" if len(i.opclasses)>0 else "") for i in index_to_create])
    logger.debug("executing sql: %s",sql)
    with connection.cursor() as cursor:
      cursor.execute(sql)
