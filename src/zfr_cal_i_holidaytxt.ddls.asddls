@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Public Holiday Text'
@ObjectModel.dataCategory: #TEXT
define view entity Zfr_CAL_I_HOLIDAYTXT
  as select from zfr_cal_holitxt
  association to parent ZFR_CAL_I_HOLIDAY as _Public_Holiday on $projection.HolidayId = _Public_Holiday.HolidayId
  association [0..*] to I_LanguageText            as _LanguageText   on $projection.Language  = _LanguageText.LanguageCode
{
      @Semantics.language: true
  key spras            as Language,
  key holiday_id       as HolidayId,
      @Semantics.text: true
      fcal_description as HolidayDescription,
      _Public_Holiday,
      _LanguageText
}
