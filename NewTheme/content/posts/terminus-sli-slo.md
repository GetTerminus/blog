---
title: "Terminus SLI & SLO"
date: 2019-03-01T10:37:23-05:00
draft: true
---

# Introduction to SLIs & SLOs
Our system at Terminus has a lot of interconnected and interdependent services. With an ever growing system, how would we know our system is reliable with these compounding factors? How do we define that our service is up? “Up” meaning reliability and availability which are determined by our SLOs and SLIs. 

For a little background on what SLIs and SLOs are please click here and here. After researching and reading the contents I finally had enough information and management support to implement this new paradigm with our new service. 

## The Challenge
For our new service we addressed other SLIs and SLOs requirements. But there were two questions asked by my manager which were difficult to address. The questions were, “How do we alert within the first 5 mins of this new service if we’re going to burn through our error budget for the month? Also, how do we alert within the day if we’re going to burn through our error budget for the month?” 

Great questions! Which, I was struggling to answer. As I fished for clues ultimately he wanted a performance Fastburn alert and a performance Slowburn alert to notify the team when the percent change passes a certain number. 

### Brainstorming 
How do I solve this challenge? I needed to use our existing infrastructure (Terraform, Datadog, and Pager Duty) to build this alert. Our service is written in Go, which has all the appropriate tags being passed to StatsD which feeds into Datadog. I needed to implement the percent change using the query in Datadog. After researching many Datadog articles (Arithmetic, Timeshift, Count, etc.) I found the article which solved these questions. 

### Fastburn
For the Fastburn I went with a time_window of 5 mins and compared the current hour minus the previous hour. If the percent change is over 50% an alert will trigger. Example, 

sum(last_5m):( ( avg:JobStatusV2.ExternalAPI.execution_ms.count{method:/api_v2.job_management.jobmanagement/authorize} - hour_before(avg:JobStatusV2.ExternalAPI.execution_ms.count{method:/api_v2.job_management.jobmanagement/authorize}) ) / hour_before(avg:JobStatusV2.ExternalAPI.execution_ms.count{method:/api_v2.job_management.jobmanagement/authorize}) ) * 100 > 50

### Slowburn
For the Slowburn I went with a time_window of 1 day and compared the current week minus the previous week. If the percent change is over 90% an alert will trigger. Example, 

sum(last_1d):( ( avg:JobStatusV2.ExternalAPI.execution_ms.count{method:/api_v2.job_management.jobmanagement/authorize} - week_before(avg:JobStatusV2.ExternalAPI.execution_ms.count{method:/api_v2.job_management.jobmanagement/authorize}) ) / week_before(avg:JobStatusV2.ExternalAPI.execution_ms.count{method:/api_v2.job_management.jobmanagement/authorize}) ) * 100 > 90

## Current State
Now that the mechanism for triggering the alerts are set up, how do we address the error budget? Specifically, // more to follow...
