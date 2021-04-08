CLASS zfr_th_bc_injector DEFINITION
  PUBLIC
  FINAL
  FOR TESTING
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS set_transport_api IMPORTING transport_api TYPE REF TO zfr_if_bc_transport_api.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zfr_th_bc_injector IMPLEMENTATION.
  METHOD set_transport_api.
    zfr_cl_bc_transport_api_f=>transport_api = transport_api.
  ENDMETHOD.
ENDCLASS.
