CLASS zFR_cl_bc_transport_api DEFINITION PUBLIC FINAL CREATE PROTECTED GLOBAL FRIENDS zFR_cl_bc_transport_api_f.
  PUBLIC SECTION.
    INTERFACES zfr_if_bc_transport_api.

    METHODS:
      constructor
        IMPORTING
          client_field             TYPE string
          use_table_scomp_transport TYPE abap_bool DEFAULT abap_false.

  PRIVATE SECTION.
    TYPES: BEGIN OF table_key,
             table TYPE tabname,
             keys TYPE REF TO data,
           END OF table_key,
           table_keys TYPE SORTED TABLE OF table_key WITH UNIQUE KEY table.
    DATA: transport_api            TYPE REF TO if_a4c_bc_handler,
          client_field             TYPE string,
          use_table_scomp_transport TYPE abap_bool,
          xco_transports           TYPE REF TO if_xco_cp_transports_factory,
          xco_filter               TYPE REF TO if_xco_cp_tr_filter_factory.
    METHODS transport
      IMPORTING
        check_mode       TYPE abap_bool
        table_keys       TYPE table_keys
        transport_request TYPE sxco_transport OPTIONAL
      RETURNING
        VALUE(result)    TYPE if_a4c_bc_handler=>tt_message.
    METHODS get_a4c_transport_api RETURNING VALUE(result) TYPE REF TO if_a4c_bc_handler.
    METHODS get_table_scomp_transport
      IMPORTING tabname      TYPE tabname
      RETURNING VALUE(result) TYPE sxco_transport.
    METHODS get_xco_transports
      RETURNING VALUE(result) TYPE REF TO if_xco_cp_transports_factory.
    METHODS get_xco_filter
      RETURNING VALUE(result) TYPE REF TO if_xco_cp_tr_filter_factory.
ENDCLASS.



CLASS zfr_cl_bc_transport_api IMPLEMENTATION.


  METHOD constructor.
    me->client_field = client_field.
    me->use_table_scomp_transport = use_table_scomp_transport.
  ENDMETHOD.


  METHOD get_a4c_transport_api.
    IF transport_api IS NOT BOUND.
    "  transport_api = cl_a4c_bc_factory=>get_handler( ).
    ENDIF.
    result = transport_api.
  ENDMETHOD.


  METHOD transport.
    DATA: object_keys TYPE if_a4c_bc_handler=>tt_object_tables,
          object_key TYPE if_a4c_bc_handler=>ts_object_list,
          table_ref  TYPE REF TO data.

    FIELD-SYMBOLS:
      <import_table>  TYPE ANY TABLE,
      <original_table> TYPE ANY TABLE.

    LOOP AT table_keys ASSIGNING FIELD-SYMBOL(<table_key>).
      ASSIGN <table_key>-keys->* TO <import_table>.
      CHECK <import_table> IS NOT INITIAL.

      CREATE DATA table_ref TYPE TABLE OF (<table_key>-table).
      ASSIGN table_ref->* TO <original_table>.
      <original_table> = CORRESPONDING #( <import_table> MAPPING FROM ENTITY ).

      object_key-objname = <table_key>-table.
      object_key-tabkeys = table_ref.
      APPEND object_key TO object_keys.
    ENDLOOP.
    CHECK object_keys IS NOT INITIAL.

    TRY.
        get_a4c_transport_api( )->add_to_transport_request(
          EXPORTING
            iv_check_mode         = check_mode
            it_object_tables      = object_keys
            iv_mandant_field_name = client_field
            iv_transport_request  = transport_request
          IMPORTING
            rt_messages           = result
            rv_success            = DATA(success_flag) ).

        IF success_flag NE 'S'.
          RAISE EXCEPTION TYPE cx_a4c_bc_exception.
        ENDIF.
      CATCH cx_a4c_bc_exception INTO DATA(bc_exception).
        APPEND
          VALUE #( msgty = 'E'
                   msgid = bc_exception->if_t100_message~t100key-msgid
                   msgno = bc_exception->if_t100_message~t100key-msgno
                   msgv1 = bc_exception->if_t100_dyn_msg~msgv1
                   msgv2 = bc_exception->if_t100_dyn_msg~msgv2
                   msgv3 = bc_exception->if_t100_dyn_msg~msgv3
                   msgv4 = bc_exception->if_t100_dyn_msg~msgv4 )
          TO result.
    ENDTRY.
  ENDMETHOD.


  METHOD zfr_if_bc_transport_api~transport.
    FIELD-SYMBOLS:
      <all_records> TYPE INDEX TABLE,
      <insert>     TYPE INDEX TABLE,
      <update>     TYPE INDEX TABLE,
      <delete>     TYPE INDEX TABLE,
      <row>        TYPE any.
    DATA transport TYPE sxco_transport.
    DATA table_keys TYPE table_keys.

    LOOP AT table_entity_relations ASSIGNING FIELD-SYMBOL(<table_entity_relation>).

      ASSIGN create->* TO FIELD-SYMBOL(<create_structure>).
      ASSIGN update->* TO FIELD-SYMBOL(<update_structure>).
      ASSIGN delete->* TO FIELD-SYMBOL(<delete_structure>).
      ASSIGN COMPONENT <table_entity_relation>-entity OF STRUCTURE <create_structure> TO <insert>.
      ASSIGN COMPONENT <table_entity_relation>-entity OF STRUCTURE <update_structure> TO <update>.
      ASSIGN COMPONENT <table_entity_relation>-entity OF STRUCTURE <delete_structure> TO <delete>.

      DATA: table_ref TYPE REF TO data,
            row_ref  TYPE REF TO data.
      CREATE DATA table_ref LIKE <insert>.
      CREATE DATA row_ref LIKE LINE OF <insert>.

      ASSIGN table_ref->* TO <all_records>.
      ASSIGN row_ref->* TO <row>.

      APPEND LINES OF <insert> TO <all_records>.
      APPEND LINES OF <update> TO <all_records>.
      LOOP AT <delete> ASSIGNING FIELD-SYMBOL(<delete_row>).
        <row> = CORRESPONDING #( <delete_row> ).
        APPEND <row> TO <all_records>.
      ENDLOOP.

      SORT <all_records>.
      DELETE ADJACENT DUPLICATES FROM <all_records> COMPARING ALL FIELDS.
      INSERT VALUE #( table = <table_entity_relation>-table keys = table_ref  ) INTO TABLE table_keys.
      IF me->use_table_scomp_transport = abap_true AND transport IS INITIAL. "assumption: same transport layer for all tables
        transport = get_table_scomp_transport( <table_entity_relation>-table ).
      ENDIF.
    ENDLOOP.

    DATA(messages) =
      transport(
        check_mode = abap_false
        table_keys = table_keys
        transport_request = transport ).

    IF line_exists( messages[ msgty = 'E' ] ) OR
       line_exists( messages[ msgty = 'A' ] ) OR
       line_exists( messages[ msgty = 'X' ] ).
      ASSERT 1 EQ 2.
    ENDIF.
  ENDMETHOD.


  METHOD zfr_if_bc_transport_api~validate.
    DATA reported_row_ref TYPE REF TO data.
    DATA failed_row_ref TYPE REF TO data.
    FIELD-SYMBOLS:
      <keys>           TYPE INDEX TABLE,
      <create_table>   TYPE INDEX TABLE,
      <failed_table>   TYPE INDEX TABLE,
      <failed_row>     TYPE any,
      <key_fields>     TYPE any,
      <reported_table> TYPE INDEX TABLE,
      <reported_row>   TYPE any,
      <reported_key>   TYPE any,
      <failed_key>     TYPE any,
      <reported_msg>   TYPE REF TO if_abap_behv_message.

    ASSIGN keys->*  TO <keys>.
    CHECK <keys> IS NOT INITIAL.
    ASSIGN create->* TO <create_table>.
    <create_table> = CORRESPONDING #( <keys> ).

      IF me->use_table_scomp_transport = abap_true.
      DATA(transport) = get_table_scomp_transport( table_entity_relation-table ).
    ENDIF.

    DATA(messages) =
      transport(
        check_mode = abap_true
        table_keys  = VALUE #( ( table = table_entity_relation-table keys = create ) )
        transport_request = transport ).

    IF me->use_table_scomp_transport = abap_true AND transport IS INITIAL.
      APPEND VALUE #( msgty = 'E' msgid = 'TK' msgno = '011' ) TO messages.
    ENDIF.

    CHECK messages IS NOT INITIAL.
    ASSIGN reported->* TO FIELD-SYMBOL(<reported_structure>).
    ASSIGN failed->* TO FIELD-SYMBOL(<failed_structure>).
    ASSIGN COMPONENT table_entity_relation-entity OF STRUCTURE <reported_structure> TO <reported_table>.
    ASSIGN COMPONENT table_entity_relation-entity OF STRUCTURE <failed_structure> TO <failed_table>.
    CREATE DATA reported_row_ref LIKE LINE OF <reported_table>.
    ASSIGN reported_row_ref->* TO <reported_row>.
    CREATE DATA failed_row_ref LIKE LINE OF <failed_table>.
    ASSIGN failed_row_ref->* TO <failed_row>.
    ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-tky OF STRUCTURE <reported_row> TO <reported_key>.
    ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-msg OF STRUCTURE <reported_row> TO <reported_msg>.
    ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-tky OF STRUCTURE <failed_row> TO <failed_key>.

    "transport messages are not key specific, select first one
    ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-tky OF STRUCTURE <keys>[ 1 ] TO <key_fields>.
    <reported_key> = <key_fields>.
    LOOP AT messages INTO DATA(message).
      IF message-msgty CA 'AEX'.
        DATA(validation_failed) = abap_true.
      ENDIF.
      <reported_msg> = NEW lcl_abap_behv_msg(
                     i_severity = COND #( WHEN message-msgty = 'I' THEN if_abap_behv_message=>severity-information
                                          WHEN message-msgty = 'S' THEN if_abap_behv_message=>severity-success
                                          WHEN message-msgty = 'W' THEN if_abap_behv_message=>severity-warning
                                          ELSE if_abap_behv_message=>severity-error )
                     i_msgid    = message-msgid
                     i_msgno    = message-msgno
                     i_msgv1    = message-msgv1
                     i_msgv2    = message-msgv2
                     i_msgv3    = message-msgv3
                     i_msgv4    = message-msgv4 ).
      APPEND <reported_row> TO <reported_table>.
    ENDLOOP.
    IF validation_failed = abap_true.
      <failed_table> = CORRESPONDING #( <keys> ).
    ENDIF.

  ENDMETHOD.

  METHOD get_table_scomp_transport.
    DATA(lo_database_table) = xco_cp_abap_dictionary=>database_table( CONV #( tabname ) ).

    " Determine the transport target associated with the software component
    " the database table belongs to (based on the package in which the database
    " table is contained in).
    DATA(lo_package) = lo_database_table->if_xco_ar_object~get_package( ).
    DO.
      DATA(package) = lo_package->read( ).
      IF package-property-transport_layer->value = '$SPL'.
        lo_package = package-property-super_package.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
    DATA(lo_transport_target) = package-property-transport_layer->get_transport_target( ).

    " Build the filters that shall be used for the transport query. Additional filters
    " could be added, e.g. for the owner of the transport.
    DATA(lo_request_target_filter) = get_xco_filter( )->request_target(
      xco_cp_abap_sql=>constraint->equal( lo_transport_target->value )
    ).
    DATA(lo_request_type_filter) = get_xco_filter( )->request_type(
      xco_cp_transport=>type->customizing_request
    ).
    DATA(lo_status_filter) = get_xco_filter( )->status(
      xco_cp_transport=>status->modifiable
    ).

    " When querying transports via XCO_CP_CTS=>TRANSPORTS both transport requests
    " and tasks will be retrieved. The "request" resolution applied below will group
    " the retrieved tasks and requests together so that only the list of transport
    " requests is returned.
    DATA(lt_transports) = get_xco_transports( )->where( VALUE #(
      ( lo_request_target_filter )
      ( lo_request_type_filter )
      ( lo_status_filter )
    ) )->resolve( xco_cp_transport=>resolution->request ).
    READ TABLE lt_transports INDEX 1 ASSIGNING FIELD-SYMBOL(<transport>).
    CHECK sy-subrc = 0.
    result = <transport>->get_request( )->value.
  ENDMETHOD.

  METHOD get_xco_transports.
    IF me->xco_transports IS NOT BOUND.
      me->xco_transports = xco_cp_cts=>transports.
    ENDIF.
    result = me->xco_transports.
  ENDMETHOD.

  METHOD get_xco_filter.
    IF me->xco_filter IS NOT BOUND.
      me->xco_filter = xco_cp_transport=>filter.
    ENDIF.
    result = me->xco_filter.
  ENDMETHOD.
ENDCLASS.
