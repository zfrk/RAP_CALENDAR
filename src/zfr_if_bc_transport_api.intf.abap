INTERFACE zFR_if_bc_transport_api PUBLIC .

  TYPES:
    BEGIN OF table_entity_relation,
      table TYPE tabname,
      entity TYPE string,
    END OF table_entity_relation,
    table_entity_relations TYPE SORTED TABLE OF table_entity_relation WITH UNIQUE KEY table.

  METHODS transport
    IMPORTING
      table_entity_relations TYPE table_entity_relations
      create                TYPE REF TO data
      update                TYPE REF TO data
      delete                TYPE REF TO data.

  METHODS validate
    IMPORTING
      table_entity_relation TYPE table_entity_relation
      keys                 TYPE REF TO data
      reported             TYPE REF TO data
      failed               TYPE REF TO data
      create               TYPE REF TO data.

ENDINTERFACE.
