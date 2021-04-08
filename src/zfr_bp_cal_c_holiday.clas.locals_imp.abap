CLASS lhc_holidayroot DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS augment_create FOR MODIFY
      IMPORTING entities FOR CREATE holidayroot.

    METHODS augment_update FOR MODIFY
      IMPORTING entities FOR UPDATE holidayroot.

ENDCLASS.

CLASS lhc_holidayroot IMPLEMENTATION.

  METHOD augment_create.
    DATA: text_cba TYPE TABLE FOR CREATE zfr_cal_i_holiday\_holidaytxt,
          myrelates         TYPE abp_behv_relating_tab.

    LOOP AT entities INTO DATA(entity).
      APPEND sy-tabix TO myrelates.
      APPEND VALUE #( %cid_ref           = entity-%cid
                      %key-holidayid     = entity-%key-holidayid
                      %is_draft          = entity-%is_draft
                      %target            = VALUE #( ( %cid               = |CREATETEXTCID{ sy-tabix }|
                                                      %is_draft          = entity-%is_draft
                                                      language           = sy-langu
                                                      holidayid          = entity-holidayid
                                                      holidaydescription = entity-HolidayDescription
                                                      %control           = VALUE #( holidayid          = if_abap_behv=>mk-on
                                                                                    language           = if_abap_behv=>mk-on
                                                                                    holidaydescription = entity-%control-holidaydescription ) ) ) )
        TO text_cba.
    ENDLOOP.

    MODIFY AUGMENTING ENTITIES OF zfr_cal_i_holiday ENTITY holidayroot CREATE BY \_holidaytxt
    FROM text_cba
    RELATING TO entities BY myrelates.
  ENDMETHOD.

  METHOD augment_update.
    DATA: text_update TYPE TABLE FOR UPDATE zfr_cal_i_holidaytxt,
          text_cba   TYPE TABLE FOR CREATE zfr_cal_i_holiday\_holidaytxt.
    DATA: myrelates_update TYPE abp_behv_relating_tab,
          myrelates_cba   TYPE abp_behv_relating_tab.

    READ ENTITIES OF zfr_cal_i_holiday
      ENTITY holidayroot BY \_holidaytxt
        FROM VALUE #( FOR holiday_entity IN entities ( %tky = holiday_entity-%tky ) )
        LINK DATA(link).

    LOOP AT entities INTO DATA(entity) WHERE %control-holidaydescription = if_abap_behv=>mk-on.
      DATA(tabix) = sy-tabix.

      "If a Description with sy-langu already exists, perform an update. Else perform a create-by-association.
      IF line_exists( link[ KEY entity source-holidayid  = entity-%key-holidayid
                                       target-holidayid  = entity-%key-holidayid
                                       target-language = sy-langu ] ).
        APPEND tabix TO myrelates_update.

        APPEND VALUE #( %key-holidayid     = entity-%key-holidayid
                        %key-language      = sy-langu
                        %is_draft          = entity-%is_draft
                        holidaydescription = entity-holidaydescription
                        %control           = VALUE #( holidaydescription = entity-%control-holidaydescription ) )
         TO text_update.
      ELSE.

        APPEND tabix TO myrelates_cba.

        APPEND VALUE #( %tky         = entity-%tky
                        %target      = VALUE #( ( %cid               = |UPDATETEXTCID{ tabix }|
                                                  holidayid          = entity-holidayid
                                                  language           = sy-langu
                                                  %is_draft          = entity-%is_draft
                                                  holidaydescription = entity-holidaydescription
                                                  %control           = VALUE #( holidayid          = if_abap_behv=>mk-on
                                                                                language           = if_abap_behv=>mk-on
                                                                                holidaydescription = entity-%control-holidaydescription ) ) ) )
          TO text_cba.
      ENDIF.
    ENDLOOP.

    MODIFY AUGMENTING ENTITIES OF zfr_cal_i_holiday
      ENTITY holidaytext UPDATE FROM text_update RELATING TO entities BY myrelates_update
      ENTITY holidayroot CREATE BY \_holidaytxt FROM text_cba RELATING TO entities BY myrelates_cba.
  ENDMETHOD.

ENDCLASS.
