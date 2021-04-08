CLASS lsc_zfr_cal_i_holiday DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zfr_cal_i_holiday IMPLEMENTATION.

METHOD save_modified.
zfr_cl_bc_transport_api_f=>get_transport_api( use_table_scomp_transport = abap_false )->transport(
    table_entity_relations = VALUE #( ( table = 'ZFR_CAL_HOLIDAY'    entity = 'HOLIDAYROOT' )
                                      ( table = 'ZFR_CAL_HOLITXT'    entity = 'HOLIDAYTEXT' ) )
    create                 = REF #( create )
    update                 = REF #( update )
    delete                 = REF #( delete )
).
ENDMETHOD.

ENDCLASS.

CLASS lhc_holidaytext DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS val_transport FOR VALIDATE ON SAVE
      IMPORTING keys FOR HolidayText~val_transport.

ENDCLASS.

CLASS lhc_holidaytext IMPLEMENTATION.

  METHOD val_transport.
    DATA create TYPE TABLE FOR CREATE zfr_cal_i_holidaytxt.
    zfr_cl_bc_transport_api_f=>get_transport_api( use_table_scomp_transport = abap_false )->validate(
        table_entity_relation = VALUE #( table = 'ZFR_CAL_HOLIDAY' entity = 'HOLIDAYTEXT' )
        keys                  = REF #( keys )
        reported              = REF #( reported )
        failed                = REF #( failed )
        create                = REF #( create )
    ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_HolidayRoot DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR HolidayRoot RESULT result.
    METHODS val_transport FOR VALIDATE ON SAVE
      IMPORTING keys FOR holidayroot~val_transport.

ENDCLASS.

CLASS lhc_HolidayRoot IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD val_transport.
    DATA create TYPE TABLE FOR CREATE zfr_cal_i_holiday.
    zfr_cl_bc_transport_api_f=>get_transport_api( use_table_scomp_transport = abap_false )->validate(
        table_entity_relation = VALUE #( table = 'ZFR_CAL_HOLIDAY' entity = 'HOLIDAYROOT' )
        keys                  = REF #( keys )
        reported              = REF #( reported )
        failed                = REF #( failed )
        create                = REF #( create )
    ).
  ENDMETHOD.

ENDCLASS.
