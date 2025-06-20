---
layout: base.html
title: Startseite
---

<p>Willkommen bei den Unterrichtsmaterialien!</p>

<h2>Fächer</h2>

<ul>
  {% for fach in site.fächer %}
    <li>
      <a href="/{{ fach.name | lower }}">{{ fach.name }}</a>
    </li>
  {% endfor %}
</ul>
