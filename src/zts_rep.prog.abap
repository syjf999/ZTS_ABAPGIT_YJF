*&---------------------------------------------------------------------*
*& Report ZTS_REP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zts_rep.
TABLES: usr02.

SELECT-OPTIONS
   s_bname FOR usr02-bname.
DATA: gt_alv LIKE TABLE OF usr02.

START-OF-SELECTION.

  SELECT * FROM usr02 INTO TABLE @gt_alv
    WHERE bname IN @s_bname.

  PERFORM frm_alv_data_1.

FORM frm_alv_data_1 .
*  快速alv显示一个内表的内容.
  DATA go_alv TYPE REF TO cl_salv_table.
  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = gt_alv[] ).
    CATCH cx_salv_msg.
  ENDTRY.
*   go_alv->display( ).
  DATA: lr_functions TYPE REF TO cl_salv_functions_list.
  lr_functions = go_alv->get_functions( ).
  lr_functions->set_all( 'X' ).
*
*... set the columns technical
*优化宽度
  DATA: lr_columns TYPE REF TO cl_salv_columns_table,
        lr_column  TYPE REF TO cl_salv_column_table.

  lr_columns = go_alv->get_columns( ).
  lr_columns->set_optimize( 'X' ).
*设置字段描述
  DEFINE  set_text.
    TRY.
        lr_column ?= lr_columns->get_column( &1 ).
        lr_column->set_short_text(  &2 ).
        lr_column->set_medium_text( &2 ).
        lr_column->set_long_text( &2 ).
      CATCH cx_salv_not_found.                          "#EC NO_HANDLER
    ENDTRY.
  END-OF-DEFINITION.
*  TRY.
*      lr_column ?= lr_columns->get_column( 'BNAME' ).
*      lr_column->set_short_text( '姓名-测试' ).
*      lr_column->set_medium_text( '姓名-测试' ).
*      lr_column->set_long_text( '姓名-测试' ).
*    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
*  ENDTRY.
  set_text 'BNAME' '姓名-测试'.
*  DATA: l_grid TYPE REF TO cl_gui_alv_grid,
*            lv_layout TYPE lvc_s_layo.
*
*  IF go_alv IS BOUND.
*    go_alv->set_screen_popup(
*      start_column = 10
*      end_column  = 150
*      start_line  = 5
*      end_line    = 20 ).
*... 设置抬头标题
  DATA: lr_display_settings TYPE REF TO cl_salv_display_settings,
        l_title             TYPE lvc_title.
  DATA: lv_lines TYPE i.
  lv_lines = lines( gt_alv ).
  l_title = '用户明细显示,条目数' && lv_lines.
  lr_display_settings = go_alv->get_display_settings( ).
  lr_display_settings->set_list_header( l_title ).
  go_alv->display( ).
*  ENDIF.
ENDFORM.
