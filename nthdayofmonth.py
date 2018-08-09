#!/usr/bin/env python2

"""Get the Nth day of the month in ISO 8601 format"""
# GNU date can probably do this, but I can't figure it out for the life of me

import argparse
import calendar
import datetime
import dateutil.relativedelta


def nthday(nth, day, mdate):
    """Calculate the Nth day of the month"""
    # Generate calendar
    cal = calendar.monthcalendar(mdate.year, mdate.month)
    # Get all the specified days
    days = [week[day - 1] for week in cal]
    # Remove any zeros (zeros indicate that week doesn't include that day)
    days = [x for x in days if x != 0]
    # Get the nth day
    return days[nth - 1]


now = datetime.date.today()

parser = argparse.ArgumentParser(
        description='Get the Nth day of the month in ISO 8601 format')
parser.add_argument('nth', help='Instance of the day in the month')
parser.add_argument('day', help='Number of the day. 1 is Monday')
parser.add_argument('--month', '-m', default=now.month)
parser.add_argument('--year', '-y', default=now.year)
parser.add_argument(
    '--past', '-p', action='store_true', 
    help='If the output date would be in the future, '
    'return the Nth day of the previous month')
args = parser.parse_args()

# Parse inputs into ints
nth = int(args.nth)
day = int(args.day)
month = int(args.month)
year = int(args.year)

# Date object to represent the month
mdate = datetime.date(year, month, 1)
# Calulate the Nth day
date = nthday(nth, day, mdate)

# If past option set, check if the date is in the future.
if bool(args.past) and (datetime.date(year, month, date) > now):
    # Repeat for previous month
    mdate = mdate - dateutil.relativedelta.relativedelta(months=1)
    date = nthday(nth, day, mdate)

# Print in ISO 8601 format
print("{:04d}-{:02d}-{:02d}".format(mdate.year, mdate.month, date))
