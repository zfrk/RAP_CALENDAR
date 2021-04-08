@EndUserText.label: 'Projection view for public holidays'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZFR_CAL_C_HOLIDAY
  provider contract transactional_query
  as projection on ZFR_CAL_I_HOLIDAY
{
  key HolidayId,
      MonthOfHoliday,
      DayOfHoliday,
      _HolidayTxt.HolidayDescription as HolidayDescription : localized,
      LastChangedAt,
      LocalLastChangedAt,
      _HolidayTxt : redirected to composition child ZFR_CAL_C_HOLIDAYTXT
}
