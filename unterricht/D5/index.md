---
layout: base
title: Deutsch
---

<p>Willkommen im Fach Deutsch!</p>

<h2>Jahrgangsstufen</h2>

<ul>
  {% for jahrgangsstufe in site.fächer[0].jahrgangsstufen %}
    <li>
      <a href="/deutsch/{{ jahrgangsstufe.name | lower }}">{{ jahrgangsstufe.name }}</a>
    </li>
  {% endfor %}
</ul>
