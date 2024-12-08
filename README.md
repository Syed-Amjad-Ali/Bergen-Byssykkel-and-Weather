# Bergen Bysykkel 2024: Cleaning, Predicting, and Mapping (Part 1)

This is Part 1 of a two-part exploration into Bergen's bicycle rental trends. In this installment, we roll up our sleeves for **data cleaning**, build **simple predictive models**, and end with a **dynamic interactive map** showcasing bike traffic across stations. Part 2 promises to dive deeper into the "data sciency" stuff, exploring advanced methods to predict ride volumes with greater precision.

## Highlights of Part 1

1. **Data Cleaning Done Right**:
   - Combined hourly bike rental data for 2024 into a clean and structured format.
   - Handled missing values and ensured consistent timestamps across stations.

2. **Simple Yet Effective Predictions**:
   - Used linear regression models to predict hourly bike rentals by station, weekday, and time of day.

3. **A Dynamic Mapping Experience**:
   - Leveraged [Leaflet](https://leafletjs.com/) to create an interactive map that visualizes station activity with color-coded markers and popups.

## What’s Coming in Part 2?

- Advanced modeling methods to predict ride volumes.
- Integration of weather data to assess its impact on bike rentals.
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
- [Hoa Nguyen’s Bergen Bysykkel Analysis](https://github.com/hoanguyen18/Bergen-Bysykkel-) for insights into regression modeling and visualization techniques, which were adapted and expanded upon independently.

## Legal and Ethical Notes

- This project references the BAN400 solution preparation material as a learning guide while ensuring originality in implementation and analysis.
- All work is aligned with NHH’s academic integrity guidelines and complies with the open-source licensing of the Bergen Bysykkel API.

---
