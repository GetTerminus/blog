---
title: "Performance Fastburn & Slowburn"
date: 2019-03-08T10:24:57-05:00
draft: true
---

# Introduction: Discovering our SLIs & SLOs
Our system at Terminus has a lot of interconnected and interdependent services. With an ever growing system, how would we know our system is reliable with these compounding factors? How do we define that our service is up? “Up” meaning reliability and availability which are determined by our SLIs & SLOs.

For a little background on what SLIs & SLOs are please click [here](https://landing.google.com/sre/books/) and [here](https://landing.google.com/sre/sre-book/chapters/service-level-objectives/). After researching and reading the contents I finally had enough information and management support to implement this new paradigm with our new service.

## The Challenge
For our new service we addressed other SLIs & SLOs requirements. But there were two questions asked by my manager which were difficult to address. The questions were, “How do we alert within the first 5 mins of this new service if we’re going to burn through our error budget for the month? Also, how do we alert within the day if we’re going to burn through our error budget for the month?”

Great questions! Which, I was struggling to answer. As I fished for clues ultimately he wanted a performance Fastburn alert and a performance Slowburn alert to notify the team when the percent change passes a certain number.

### Brainstorming
How do I solve this challenge? I needed to use our existing infrastructure (Terraform, Datadog, and Pager Duty) to build this alert. Our service is written in Go, which has all the appropriate tags being passed to StatsD which feeds into Datadog. I needed to implement the percent change using the query in Datadog. After researching many Datadog articles (Arithmetic, Timeshift, Count, etc.) I found the article which [solved](https://docs.datadoghq.com/graphing/faq/how-can-i-graph-the-percentage-change-between-an-earlier-value-and-a-current-value/) these questions.

### Fastburn
For the Fastburn I went with a [time_window](https://docs.datadoghq.com/api/?lang=python#create-a-monitor) of 5 mins (each point in the graph in Datadog reflects an evaluation window of 5m) and compared the current hour minus the previous hour. If the percent change is over 50% an alert will trigger. Example,

```
sum(last_5m):((avg:JobStatusV2.../.../.count{method:/api_v2.../.../authorize}
-
hour_before(avg:JobStatusV2.../.../.count{method:/api_v2.../...//authorize}))
/
hour_before(avg:JobStatusV2.../.../.count{method:/api_v2.../.../authorize})) * 100 > 50
```

### Slowburn
For the Slowburn I went with a time_window of 1 day (each point in the graph in Datadog reflects an evaluation window of 1d) and compared the current week minus the previous week. If the percent change is over 90% an alert will trigger. Example,

```
sum(last_1d):((avg:JobStatusV2.../.../.count{method:.../authorize}
-
week_before(avg:JobStatusV2.../.../.count{method:/api_v2.../.../authorize}))
/
week_before(avg:JobStatusV2.../.../.count{method:/api_v2.../.../authorize})) * 100 > 90
```

## Current State
Now that the mechanism for triggering the alerts are set up, how do we address the error budget? Specifically, is there a mechanism which indicates that we’re reaching the limits of our error budget? Currently, not at this time. We put specifications around these performance Fastburn and Slowburn alerts. See **Table 1** below. Datadog has a good Monitor Summary widget which shows the alerts current state (triggered or not triggered). Additionally, Datadog does have an Uptime widget as well specific to SLIs & SLOs. However, it is still in beta. But, it does show very good promise.

#### **Table 1**
| SLI | SLO |
| --- | --- |
| (Fastburn perf) Performance of endpoint summed within 5 mins as a rate of change `count of “authorize” current http_requests as avg minus by count of hour_before “authorize” http_request as avg over hour_before “authorize” http_requests as avg * 100 > 0.5` | 99.99% success in previous 5 mins. Example, Sum the data points within 5 mins between the current endpoint minus the hour_before endpoint over the hour_before endpoint multiply by 100. If the rate of change is > 50% trigger an alert. And, if 3 alerts fired within 5 mins we’ll need to investigate. |

## Conclusion
Our journey of SLIs & SLOs is ongoing. It took many months of researching, trials and errors to get to this point. I’m happy with the results my team and I achieved. Overtime the SLIs & SLOs specification will change (e.g., tighten up, or loosen of SLIs & SLOs) depending on the system or users of the service(s). But, we’re in a better place to report to our stakeholders what does it mean to be “Up”.

