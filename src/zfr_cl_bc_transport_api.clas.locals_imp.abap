CLASS lcl_abap_behv_msg DEFINITION CREATE PUBLIC INHERITING FROM cx_no_check.
  PUBLIC SECTION.
    INTERFACES if_abap_behv_message .

    METHODS constructor
      IMPORTING
        i_severity TYPE if_abap_behv_message=>t_severity
        i_msgid   TYPE sy-msgid
        i_msgno   TYPE sy-msgno
        i_msgv1   TYPE sy-msgv1
        i_msgv2   TYPE sy-msgv2
        i_msgv3   TYPE sy-msgv3
        i_msgv4   TYPE sy-msgv4.
ENDCLASS.
CLASS lcl_abap_behv_msg IMPLEMENTATION.

  METHOD constructor.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.

    if_t100_dyn_msg~msgty = CONV #( i_severity ).
    if_t100_dyn_msg~msgv1 = if_t100_message~t100key-attr1 = i_msgv1.
    if_t100_dyn_msg~msgv2 = if_t100_message~t100key-attr2 = i_msgv2.
    if_t100_dyn_msg~msgv3 = if_t100_message~t100key-attr3 = i_msgv3.
    if_t100_dyn_msg~msgv4 = if_t100_message~t100key-attr4 = i_msgv4.

    if_t100_message~t100key-msgno = i_msgno.
    if_t100_message~t100key-msgid = i_msgid.

    if_abap_behv_message~m_severity = i_severity.
  ENDMETHOD.

ENDCLASS.
