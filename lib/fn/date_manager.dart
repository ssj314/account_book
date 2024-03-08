class DateManager {

  int year;
  int month;
  int date;

  DateManager({this.year = 0, this.month = 0, this.date = 0, var init = false}) {
    if(init) initDate();
  }

  int getCurrentYear() => DateTime.now().year;
  int getCurrentMonth() => DateTime.now().month;
  int getCurrentDate() => DateTime.now().day;
  int getCurrentDay() => DateTime.now().weekday - 1;

  initDate() {
    year = getCurrentYear();
    month = getCurrentMonth();
    date = getCurrentDate();
  }

  factory DateManager.fromString(calendar) {
      var year = (calendar/10000).floor();
      calendar %= 10000;
      var month = (calendar/100).floor();
      calendar %= 100;
      var date = calendar;
      return DateManager(year: year, month: month, date: date);
  }

  set({required year, required month, required date}) {
    this.year = year;
    this.month = month;
    this.date = date;
  }

  copy() {
    return DateManager(
        year: year,
        month: month,
        date: date
    );
  }

  getYear() => year;
  getMonth() => month;
  getDate() => date;

  setYear(year) => this.year = year;
  setMonth(month) =>this.month = month;
  setDate(date) => this.date = date;


  int getFirstDay() => DateTime(year, month, 1).weekday % 7;
  int getLastDate() => DateTime(year, month + 1, 0).day;

  increaseDate() {
    if(date == getLastDate()) {
      date = 1;
      increaseMonth();
    } else {
      date += 1;
    }
  }

  decreaseDate() {
    if(date == 1) {
      decreaseMonth();
      date = getLastDate();
    } else {
      date -= 1;
    }
  }

  increaseMonth() {
    if (month == 11) {
      month = 12;
    } else if (month == 12) {
      month = 1;
      year ++;
    } else {
      month ++;
    }
  }

  decreaseMonth() {
    if (month == 1) {
      month = 12;
      year -= 1;
    } else {
      month = (month - 1) % 12;
    }
  }

  setCalendar({required year, required month, required date}) {
    setYear(year);
    setMonth(month);
    setDate(date);
  }

  getCalendar({year = -1, month = -1, date = -1}) {
    if(year == -1) year = this.year;
    if(month == -1) month = this.month;
    if(date == -1) date = this.date;
    if(month > 12) {
      year += 1;
      month = 1;
    }

    return year * 10000 + month * 100 + date;
  }

  compareDate(date) {
    if (getCurrentYear() > year) {
      return -1;
    } else if(getCurrentYear() == year && getCurrentMonth() > month) {
      return -1;
    } else if(isCurrentMonth() && getCurrentDate() > date) {
      return -1;
    } else if(isCurrentMonth() && getCurrentDate() == date){
      return 0;
    } else {
      return 1;
    }
  }

  isCurrentMonth() {
    if(getCurrentYear() == year && getCurrentMonth() == month) {
      return true;
    } else {
      return false;
    }
  }

  isMonday(){
    if(DateTime.now().weekday == DateTime.monday) {
      return true;
    } else {
      return false;
    }
  }

  @override
  toString() {
    String str = "$year년 $month월";
    if(date > 0) str += " $date일";
    return str;
  }

  subtract(int value) {
    for(int i = 0; i < value; i ++) {
      decreaseDate();
    }
  }

  getWeekNumber() {
    int firstDay = getFirstDay();
    int weeks = (firstDay > 4)?0:1;
    for(int i = 0; i < date; i++) {
      firstDay = (firstDay + 1) % 7;
      if(firstDay == 1) weeks += 1;
    }
    return weeks;
  }

  getSundayCount() {
    int firstDay = getFirstDay();
    int weeks = 0;
    for(int i = 0; i < date; i++) {
      firstDay = (firstDay + 1) % 7;
      if(firstDay == 1) weeks += 1;
    }
    return weeks;
  }
}