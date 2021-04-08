CLASS zfr_cl_bc_transport_api_f DEFINITION PUBLIC FINAL CREATE PUBLIC
   GLOBAL FRIENDS zfr_th_bc_injector.
  PUBLIC SECTION.
    CLASS-METHODS get_transport_api
      IMPORTING
        client_field TYPE string DEFAULT 'CLIENT'
        use_table_scomp_transport type abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result) TYPE REF TO zfr_if_bc_transport_api.
  PRIVATE SECTION.
    CLASS-DATA transport_api TYPE REF TO zfr_if_bc_transport_api.
ENDCLASS.



CLASS zfr_cl_bc_transport_api_f IMPLEMENTATION.
  METHOD get_transport_api.
    IF transport_api IS BOUND.
      result = transport_api.
    ELSE.
      result = NEW zfr_cl_bc_transport_api(
        client_field        = client_field
        use_table_scomp_transport = use_table_scomp_transport
      ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
