---
title: "Scale-free software"
date: 2020-08-02T00:00:00-00:00
---

Good software engineering is concerned with two kinds of scale: operational scale and engineering scale.

**Operational scale** measures how many processors and compute nodes are in your production infrastructure, and how many requests and responses the system handles every second. The higher these numbers, the greater the operational scale. Operational scaling problems are caused by single points of dependency that become bottlenecks, like an implicit assumption on a single database, or an algorithm that becomes slow with large datasets in a critical path.

**Engineering scale** is about the _production_ of software. Software evolves over time, and maintaining software systems gets more difficult with time, and with larger teams in large organizations. Software without well-designed interfaces between components or poorly documented APIs will get more difficult to maintain as a team grows to hundreds and thousands of people. Well-designed software systems scale well in this engineering axis, as well as servicing a high operational workload.

Engineering scale is especially important for open source projects, where potentially tens of thousands of relative strangers need to come together and converge on what to build, how to design it, and how to contribute to a single project in a way that stabilizes and guarantees a future for the project.

To build scalable software, we need to service both of these independent axes of operational and engineering scale.

I'm not sure where I first heard it, but I recently heard the phrase "scale-free software" and thought it was an interesting way to think about composing large scalable software systems.

## Scale-free software primitives

I think whenever possible, **large scalable software systems are best composed of small, scale-free parts**.

A scale-free software component is one that doesn't need to change behavior as a result of scale. Scale-free components are desirable because large scalable systems can be composed straightforwardly out of scale-free parts, whereas if those components had to change as the size of the problem increased, scaling the whole system would require lots of understanding and thinking across layers of abstraction.

In achieving operational scale, two common scale-free primitives are embarrassingly parallel problems and purely functional algorithms. Both kinds of paradigms allow components to be written in a way such that a macroscopic system can scale the number of components in a system freely to scale throughput, without each component having to account for scaling effects to its particular implementation. These components can also readily take advantage of parallelism.

In a more practical context, a well-designed microservice architecture is a scalable system composed of scale-free parts. Ideally, each microservice exhibits the same behavior regardless of whether there is one instance running or ten million. The problem of coordinating these scale-free components is relegated to a specific part of the macroscopic system like a service mesh, and wherever that encapsulation holds, each microservice can be designed without worrying about emergent problems of scale.

What does scale-free design look like in achieving engineering scale?

I think the theme of scale-free design in collaboration is good interface design. Interfaces between software components include the literal interfaces of the APIs, but also things like release schedules, deprecation timelines, and versioning schemes. Designing and agreeing on a common set of interfaces, writ large like this, allows each specific sub-team to work more independently, and allows the entire organization to grow by adding more teams, not necessary perfectly, but more easily than would otherwise be possible.

Large open source ecosystems built around semantic versioning, like Node's NPM ecosystem and Rust's Crate repository, are good examples of engineering scale that's seen success by building on well-defined interfaces between software components. There are exceptions, yes, but those exceptions prove the rule.

Another place to make engineering team components more scale-free is by being more diligent about the dependencies a project takes on. An external software dependency is another engineering team whose output matters in the current project, and we should strive to narrow those points of integration and scope them to be as stable and uninterruptive as possible.

When we compose large systems from smaller scale-free components, it's easier to abstract away effects of scale to the macroscopic system, while letting the authors and operation of each component worry about their specific problems. This doesn't mean each component can be written with complete disregard to performance or efficiency. Rather, composing large systems like this allows each component to only worry about performance problems at its level of abstraction. Importantly, complexities of large distributed services like consensus and availability can be relegated to the higher levels of design, where components are fit together, while each component service can worry about the efficient implementation of its own job.
