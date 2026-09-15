*&---------------------------------------------------------------------*

*& Include zfi00XX_001_01

*&---------------------------------------------------------------------*

" BR: Payment Clearing Enhancement

zclfi00XX_001_01=>exit_rfebbu10_001( EXPORTING in_febko  = i_febko

                                               in_febep  = i_febep

                                     IMPORTING out_febep = e_febep

                                               febcl_t   = t_febcl[] ).
