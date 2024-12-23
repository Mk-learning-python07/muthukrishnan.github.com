---
layout: default
title: About Me
permalink: /about-me/
---
# About Me

Growing up in a developing country like India, I was acutely aware of the challenges that come with limited access to resources and the growing need for sustainable solutions. Raised in an environment where affordable energy and technology were often scarce, I was inspired by the idea that science and engineering could be the driving forces to overcome these limitations. This curiosity and drive led me to pursue a degree in **Chemical Engineering** at **National Institute of Technology (NIT) Trichy**, one of India’s premier institutions. My academic journey, combined with my passion for problem-solving, deepened my commitment to harnessing science for the betterment of humanity.

During my undergraduate years, I became increasingly interested in energy security and sustainability. My education provided me with a solid foundation in these fields, but it was my **5 years of professional experience at ExxonMobil** that truly shaped my expertise. In this role, I tackled multifaceted problems across energy production, process optimization, and operational efficiency. I was able to demonstrate significant results in **energy efficiency improvements, process enhancements, and troubleshooting**, all of which provided valuable insights into the practical applications of engineering solutions in the energy sector.

Currently, I am pursuing my **Master’s degree in Chemical and Materials Engineering** at **University of Alberta**, working under the guidance of **Prof. Arvind Rajendran**. This phase of my education is allowing me to perform cutting-edge research in  **Direct Air Capture (DAC)** by utilizing **gas adsorption technologies**. These are at the forefront of sustainable energy solutions, and I am focused on developing innovative methods to address global carbon emissions challenges and advance the transition to low-carbon energy systems. My goal is to leverage both my industry experience and academic background to develop scalable and sustainable solutions that contribute to the global transition to low-carbon energy systems. With a deep-rooted passion for solving complex challenges, I am committed to advancing sustainability and driving change for a better future.


I’ve always had a passion for continuous learning and solving complex problems, especially when it comes to technology and sustainability. Outside of work, I’m deeply into music, cricket, and enjoy indulging in sci-fi and crime thrillers, whether in movies or novels—they’re my go-to for staying creative and energized. Traveling and exploring new places also bring me joy, allowing me to immerse myself in different cultures. Fluent in three languages, I appreciate the ability to connect with people from diverse backgrounds. Above all, I believe in the importance of acting now for a sustainable future, and I’m committed to being part of solutions that truly make a difference.

![Collage Image]({{ site.baseurl }}/Files/Collage.png)

# **Softskills and Interests**

<!-- Softskills and Interests Section -->
<div class="skills-container">
  <div class="skills-column">
    <h4>LANGUAGES</h4>
    <div class="icon-item">
      <img src="{{ site.baseurl }}/Files/en-icon.png" alt="English" class="custom-icon" title="English">
      <p>English</p>
    </div>
    <div class="icon-item">
      <img src="{{ site.baseurl }}/Files/ta-icon.png" alt="Tamil" class="custom-icon" title="Tamil">
      <p>Tamil</p>
    </div>
    <div class="icon-item">
      <img src="{{ site.baseurl }}/Files/hi-icon.png" alt="Hindi" class="custom-icon" title="Hindi">
      <p>Hindi</p>
    </div>
  </div>

  <div class="interest-column">
    <h4>PERSONAL INTERESTS</h4>
    <div class="icon-item">
      <img src="{{ site.baseurl }}/Files/travel-icon.png" alt="Travel" class="custom-icon" title="Travel">
      <p>Travel</p>
    </div>
    <div class="icon-item">
      <img src="{{ site.baseurl }}/Files/crime-icon.png" alt="Crime Thrillers" class="custom-icon" title="Crime Thrillers">
      <p>Crime Thrillers</p>
    </div>
    <div class="icon-item">
      <img src="{{ site.baseurl }}/Files/motorcycle-icon.png" alt="Motorcycles" class="custom-icon" title="Motorcycles">
      <p>Motorcycles</p>
    </div>
    <!-- Music and Movies with image icons -->
    <div class="icon-item">
      <img src="{{ site.baseurl }}/Files/music.png" alt="Music" class="custom-icon" title="Music">
      <p>Music</p>
    </div>
    <div class="icon-item">
      <img src="{{ site.baseurl }}/Files/movies.png" alt="Movies" class="custom-icon" title="Movies">
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
  border: 2px solid #2980b9;  /* Add a blue border on hover/focus for better accessibility */
  padding: 2px;
}

.icon-item:focus .custom-icon, .icon-item:hover .custom-icon {
  transform: scale(1.1);
  box-shadow: 0px 5px 15px rgba(0, 0, 0, 0.1);
}

.icon-item:focus p, .icon-item:hover p {
  color: #2980b9;  /* Change text color on hover and focus */
}
</style>
