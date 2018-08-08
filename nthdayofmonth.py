#!/usr/bin/env python2

# Get the Nth day of the month in ISO 8601 format
# GNU date can probably do this, but I can't figure it out for the life of me

import argparse
import calendar
from datetime import datetime

now = datetime.now()

parser = argparse.ArgumentParser(description='Get the Nth day of the month in ISO 8601 format')
parser.add_argument('nth', help='Instance of the day in the month')
parser.add_argument('day', help='Number of the day. 1 is Monday')
parser.add_argument('--year','-y', default=now.year)
parser.add_argument('--month','-m', default=now.month)
args = parser.parse_args()

# generate calendar
cal = calendar.monthcalendar(int(args.year), int(args.month))
# get all the specified days
days = [week[int(args.day) - 1] for week in cal]
# remove any zeros indicating that week doesn't include that day
days = [x for x in days if x != 0]
# get the nth day
date = days[int(args.nth) - 1]

# Print in ISO 8601 format
print("{:04d}-{:02d}-{:02d}".format(int(args.year), int(args.month), date))
