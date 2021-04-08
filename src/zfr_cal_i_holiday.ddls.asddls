@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '<span class="sapedia-acronym" data-template="sapediaAdCDS" aria-expanded="false">CDS</span> View for public holidays'
define root view entity ZFR_CAL_I_HOLIDAY
  as select from zfr_cal_holiday
  composition [0..*] of Zfr_CAL_I_HOLIDAYTXT  as _HolidayTxt
{
key holiday_id as HolidayId,
@Semantics.calendar.month: true
month_of_holiday as MonthOfHoliday,
@Semantics.calendar.dayOfMonth: true
day_of_holiday as DayOfHoliday,
@Semantics.systemDateTime.lastChangedAt: true
last_changed_at as LastChangedAt,
@Semantics.systemDateTime.localInstanceLastChangedAt: true
local_last_changed_at as LocalLastChangedAt,
_HolidayTxt
}
