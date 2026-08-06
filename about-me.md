---
layout: default
title: About Me
permalink: /about-me/
---
# **About Me**

Growing up in India, I was inspired by the idea that engineering could solve resource scarcity. This led me to pursue **Chemical Engineering** at **NIT Trichy**, which provided the foundation for my 5-year tenure at **ExxonMobil**.

Currently, as an **M.Sc. candidate** at the **University of Alberta**, I am investigating the optimization of structured adsorbents for carbon capture under **Prof. Arvind Rajendran**. My work bridges the gap between field-proven operations and the scale-up of **Pressure Vacuum Swing Adsorption (PVSA)** technology. 

---

### **Core Expertise**

<div style="display: flex; justify-content: space-between; flex-wrap: wrap; text-align: center;">
  <div style="flex: 1; min-width: 150px;">
    <img src="{{ site.baseurl }}/Files/python.png" style="width: 50px;" alt="Python">
    <p>Data Analytics</p>
  </div>
  <div style="flex: 1; min-width: 150px;">
    <img src="{{ site.baseurl }}/Files/aspen-hysys.png" style="width: 50px;" alt="HYSYS">
    <p>Process Modeling</p>
  </div>
  <div style="flex: 1; min-width: 150px;">
    <img src="{{ site.baseurl }}/Files/seeq.png" style="width: 50px;" alt="SEEQ">
    <p>Asset Surveillance</p>
  </div>
</div>

---

Outside of engineering, I am passionate about music, cricket, and sci-fi thrillers. Fluent in three languages, I enjoy connecting with people from diverse backgrounds to drive a sustainable future.

[Connect on LinkedIn]({{ site.linkedin }}) | [View Research]({{ site.baseurl }}/research/)

<img src="{{ site.baseurl }}/Files/Collage.png" alt="Collage Image" loading="lazy">


---

# **Softskills and Interests**

<!-- Softskills and Interests Section -->
<div class="skills-container">
  <div class="skills-column">
    <h4>LANGUAGES</h4>
    <div class="icon-item">
      <img src="{{ site.baseurl }}/Files/en-icon.png" alt="English" class="custom-icon" title="English" loading="lazy">
      <p>English</p>
    </div>
    <div class="icon-item">
      <img src="{{ site.baseurl }}/Files/ta-icon.png" alt="Tamil" class="custom-icon" title="Tamil" loading="lazy">
      <p>Tamil</p>
    </div>
    <div class="icon-item">
      <img src="{{ site.baseurl }}/Files/hi-icon.png" alt="Hindi" class="custom-icon" title="Hindi" loading="lazy">
      <p>Hindi</p>
    </div>
  </div>

  <div class="interest-column">
    <h4>PERSONAL INTERESTS</h4>
    <div class="icon-item">
      <img src="{{ site.baseurl }}/Files/travel-icon.png" alt="Travel" class="custom-icon" title="Travel" loading="lazy">
      <p>Travel</p>
    </div>
    <div class="icon-item">
      <img src="{{ site.baseurl }}/Files/crime-icon.png" alt="Crime Thrillers" class="custom-icon" title="Crime Thrillers" loading="lazy">
      <p>Crime Thrillers</p>
    </div>
    <div class="icon-item">
      <img src="{{ site.baseurl }}/Files/motorcycle-icon.png" alt="Motorcycles" class="custom-icon" title="Motorcycles" loading="lazy">
      <p>Motorcycles</p>
    </div>
    <!-- Music and Movies with image icons -->
    <div class="icon-item">
      <img src="{{ site.baseurl }}/Files/music.png" alt="Music" class="custom-icon" title="Music" loading="lazy">
      <p>Music</p>
    </div>
    <div class="icon-item">
      <img src="{{ site.baseurl }}/Files/movies.png" alt="Movies" class="custom-icon" title="Movies" loading="lazy">
      <p>Movies</p>
    </div>
  </div>
</div>

<!-- CSS for Styling -->
<style>
/* General layout for the Skills and Interests Sections */
.skills-container {
  display: flex;
  justify-content: space-between;  /* Ensure space between columns */
  margin: 40px 0;
  flex-wrap: wrap;  /* Allow items to wrap on smaller screens */
  gap: 30px; /* Space between columns */
  align-items: flex-start; /* Align items at the top for consistency */
}

/* Column Styling for Skills and Interests */
.skills-column, .interest-column {
  width: 45%;  /* Adjust width so they fit on the same row */
  text-align: center;
  margin-bottom: 20px;  /* Ensure space between columns on mobile */
  box-sizing: border-box; /* Prevent layout shifts */
  display: flex;
  flex-direction: column;
  justify-content: flex-start; /* Align items to the top */
  height: 100%; /* Ensure columns take full height of container */
}

/* Icon Item Styling */
.icon-item {
  margin: 20px 0;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  display: flex;
  justify-content: center;
  align-items: center;
  flex-direction: column; /* Stack icon and text vertically */
  min-height: 120px; /* Ensures consistent height for icon items */
  cursor: pointer;
}

/* Icon Text Styling */
.icon-item p {
  font-size: 1rem;
  color: #7f8c8d; /* Base color set to grey */
  transition: color 0.3s ease; /* Smooth transition for text color */
  margin-top: 10px;
}

/* Unified Hover Effects for Icons */
.icon-item:hover .custom-icon, .icon-item:focus .custom-icon {
  transform: scale(1.1);
  box-shadow: 0px 5px 15px rgba(0, 0, 0, 0.1); /* Add a subtle shadow on hover */
}

.icon-item:hover p, .icon-item:focus p {
  color: #2980b9;  /* Change text color to blue on hover */
}

/* Icon Image Styling */
.custom-icon {
  width: 60px;
  height: 60px;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  object-fit: contain; /* Ensure images maintain aspect ratio */
}

/* Heading Styling */
.skills-column h4, .interest-column h4 {
  font-size: 1.5rem;
  margin-bottom: 20px;
  color: #7f8c8d; /* Set the base heading color to grey */
  font-weight: 600;  /* Make headings more prominent */
  text-transform: uppercase;  /* Add emphasis on headings */
}

/* Styling for Icon Items in each Column */
.skills-column .icon-item, .interest-column .icon-item {
  margin: 10px 0;
}

/* Responsive Design: Stack columns on smaller screens */
@media (max-width: 768px) {
  .skills-column, .interest-column {
    width: 100%;
    margin-bottom: 20px;  /* Space between columns on mobile */
  }

  .custom-icon {
    width: 50px;
    height: 50px;
  }

  .skills-column h4, .interest-column h4 {
    font-size: 1.2rem;  /* Adjust font size for mobile */
  }
}

/* Accessibility: Ensure hover and focus effects are clear */
.icon-item:focus, .icon-item:hover {
  outline: none;  /* Remove default outline */
  
  padding: 2px;
}

.icon-item:focus .custom-icon, .icon-item:hover .custom-icon {
  transform: scale(1.1);
  box-shadow: 0px 5px 15px rgba(0, 0, 0, 0.1);
  border: 2px solid #2980b9;  /* Add a blue border on hover/focus for better accessibility */
}

.icon-item:focus p, .icon-item:hover p {
  color: #2980b9;  /* Change text color on hover and focus */
}
</style>
