# Bergen Bysykkel 2024: R Edition- Cleaning, Predicting, and Mapping (Part 1)

This is Part 1 of a two-part exploration into Bergen's bicycle rental trends. In this installment, we roll up our sleeves for **data cleaning**, build **simple predictive models**, and end with a **semi-interactive map** showcasing bike traffic across stations. Part 2 promises to dive deeper into the "data sciency" stuff, exploring advanced methods to predict ride volumes with greater precision.

## Data Sources

- **[Bysykkel Data](https://bergenbysykkel.no/apne-data/historisk)**: Historical bike rental data provided by Bergen Bysykkel.
- **[Weather Data](https://seklima.met.no/observations/?fbclid=IwY2xjawHC3BlleHRuA2FlbQIxMAABHR-1J8AxQO7W68khnBEDM7aVue4GLeWghu0CrBYHs3b1dowE8Wq2u1oBXQ_aem_HFWzKgdTgLH6cHBCCTq4RA)**: Hourly weather observations obtained from SeKlima.


## Highlights of Part 1

1. **Data Cleaning Done Right**:
   - Combined hourly bike rental data for 2024 into a clean and structured format.
   - Handled missing values and ensured consistent timestamps across stations.

2. **Simple Yet Effective Predictions**:
   - Linear regression models were used to predict hourly bike rentals by station, weekday, and time of day.

3. **A Dynamic Mapping Experience**:
   - Leveraged [Leaflet](https://leafletjs.com/) to create a semi-interactive map visualizing station activity with color-coded markers and popups.

## What’s Coming in Part 2?

- Advanced modeling methods to predict ride volumes.
- Weather data will be integrated to assess its impact on bike rentals.
- Comparative analysis of model performances.

Stay tuned as we transition from foundational data cleaning to cutting-edge modeling techniques!

## Getting Started

### Requirements
- R version >= 4.0
- Required packages: `tidyverse`, `magrittr`, `ggplot2`, `leaflet`, etc.

### Steps to Reproduce
1. Clone the repository.
2. Run the provided R Markdown file to generate the HTML report.


## Inspiration and Acknowledgments

This project builds on the **BAN400** course at the [Norwegian School of Economics (NHH)](https://www.nhh.no/en/courses/r-programming-for-data-science/). The analysis was inspired by:
- Problem statements and solution preparation guides provided in the Fall 2021 home exam for BAN400.
- [Hoa Nguyen’s Bergen Bysykkel Analysis](https://github.com/hoanguyen18/Bergen-Bysykkel-), which used the 2021 dataset, this project introduces adjustments and utilizes a renewed 2024 dataset for updated insights.

A notable difference in this project is the use of the leaflet package for geospatial visualization. Unlike other approaches that rely on APIs with restricted access, leaflet offers a free and open API for interactive maps. This choice enhances the accessibility and reproducibility of the analysis while delivering a highly engaging user experience with features like zoom controls, hover effects, and categorized markers.

## Legal and Ethical Notes

- This project references the BAN400 solution preparation material as a learning guide while ensuring originality in implementation and analysis.
All work is aligned with NHH’s academic integrity guidelines and complies with the Bergen Bysykkel API's open-source licensing.

---
