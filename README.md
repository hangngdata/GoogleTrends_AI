# Where in the world is the most interested in AI?

AI is blowing up worldwide. Over the past years, terms like "Artificial Intelligence", "Machine Learning", "Generative AI" and "Large Language Models" are being searched on Google more than ever. Where is the buzz coming from? Who have been searching the most?

In this mini-project, I tracked how interest in the AI concepts "LLM", "GenAI" and "Agentic AI" via Google search grew in the last 5 years. I also looked into which countries searched for these keywords the most to see how the attention shifted around the world. Using ``gtrendsR`` package and visualization in R, I uncovered the upward trends in global curiosity and how East and Southest Asian countries like China, Singapore, Hong Kong and South Korea are now leading the AI search race.

## Data and preprocessing

I used the Google Trends API via the ``gtrendsR`` package to get the data like interest over time and top countries by year. Related topics and related queries features were also documented, but returned NULL for any keyword at the time of this project.

Regarding interest over time, I searched for trends since 1 Janurary 2021 continuously to 18 July 2025. To figure out the top countries, I queried the trend for each year and extracted the top 5 countries.

The plots were made with ``ggplot2``, ``ggbump`` and ``shadowtext`` in R.

## LLM and GenAI take off in 2023, Agentic AI recently grow

[!alt-text] [plots/ltrend_plot.png]

There was a sharp rise in the search for "LLM" since the beginning of 2023, possibly in response to ChatGPT boom and foundation model hype. "GenAI" has gained attention steadily since mid-2023. "Agentic AI" is starting the trends only in 2025.

## Asia is getting interested in LLM and GenAI recently

[!alt-text] [plots/llm_top_countries.png]

Maritius, India, Pakistan and Ghana were the top searchers for "LLM" in 2021 and 2022. Since 2023, China, Singapore, South Korea and Hong Kong have consistently become dominated.

[!alt-text] [plots/genai_top_countries.png]

Belize, Lithuania, Brazil, Egypt and Indonesia topped the list of searching for "GenAI" in 2021 before Belize and Indonesia dropped out of top 5 in the next four years. Zimbawe and Ukraine appeared once in 2022 as the second and fourth top searchers. Switzerland was found in the fifth place for 2 years in 2023 and India in the fourth position in 2024 and 2025. Hong Kong, Singapore and China have consistently held the top spots in the past three years.
