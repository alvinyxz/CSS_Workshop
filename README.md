# Syllabus

- **Date:** June 2–6 and June 9–10, 2025
- **Time:** Every day, 9:00 AM–12:00 PM and 1:00 PM–4:00 PM; Catered Lunch on Day 1 and Day 6 after guest lectures
- **Location:** In person, Room 32 (basement), Murphy Hall, UMN Twin Cities

Welcome to the inaugural Computational Social Science (CSS) Workshop, hosted by the College of Liberal Arts (CLA) Data Science Initiative at the University of Minnesota.

Over the course of seven days, we will explore various topics and methodologies in computational social science, as well as discuss classic readings and recent advances. We will also engage in hands-on activities and collaborative projects to enrich our learning experience.

All learning materials, including the syllabus, readings, sample data, and coding scripts, will be hosted on this GitHub page: https://z.umn.edu/CSS_Workshop As content may evolve during the week, I encourage you to check the page regularly for the most current information.

The GitHub page is organized into eight folders (Day 0 through Day 7), each corresponding to a workshop day, with Day 0 providing start-up information that you need to complete before starting the workshop. In each folder, you will find a corresponding ".md" file that introduces the class content and serves as the guide for that day's material.

## Schedule

### Day 0 - Foundational Readings

- **Readings:** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day0
  - Lazer, D., Pentland, A., Adamic, L., Aral, S., Barabasi, A.-L., Brewer, D., Christakis, N., Contractor, N., Fowler, J., Gutmann, M., Jebara, T., King, G., Macy, M., Roy, D., & Van Alstyne, M. (2009). Computational social science. *Science, 323*(5915), 721–723. https://doi.org/10.1126/science.1167742
  - Lazer, D., Pentland, A., Watts, D. J., Aral, S., Contractor, N., Freelon, D., Gonzalez-Bailon, S., King, G., Nelson, A., Salganik, J., Strohmaier, M., Vespignani, A., & Wagner, C. (2020). Computational social science: Obstacles and opportunities. *Science, 369*(6507), 1060–1062. https://doi.org/10.1126/science.aaz8170
  - Lazer, D., Hargittai, E., Freelon, D., Gonzalez-Bailon, S., Munger, K., Ognyanova, K., & Radford, J. (2021). Meaningful measures of human society in the twenty-first century. *Nature, 595*(7866), 189–196. https://doi.org/10.1038/s41586-021-03660-7
  - Hofman, J. M., Watts, D. J., Athey, S., Garip, F., Griffiths, T. L., Kleinberg, J., Margetts, H., Mullainathan, S., Salganik, M. J., Vazire, S., Vespignani, A., & Yarkoni, T. (2021). Integrating explanation and prediction in computational social science. *Nature, 595*(7866), 181–188. https://doi.org/10.1038/s41586-021-03659-0
  - Wallach, H. (2018). Computational social science ≠ computer science + social data. *Communications of the ACM, 61*(3), 42–44. https://doi.org/10.1145/3132698

### Day 1 - Welcome and Get Ready

- **Morning**
  - **[Solomon Messing](https://solomonmg.github.io/) Guest Lecture with Catered Lunch**
  - **Readings:**
    - Aggarwal, M., Allen, J., Coppock, A., Frankowski, D., Messing, S., Zhang, K., Barnes, J., Beasley, A., Hantman, H., & Zheng, S. (2023). A 2 million-person, campaign-wide field experiment shows how digital advertising affects voter turnout. *Nature Human Behaviour, 7*(3), 332–341. https://doi.org/10.1038/s41562-022-01487-4
    - A secret embargoed paper to be sent via email; please do not share it with anyone outside the workshop---there is legal liability for doing so.
- **Afternoon**
  - **Seminar - Welcome:** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day1/Day1.pdf
  - **Lab - Get Started with R/Python:** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day1/Lab/Day1.md

### Day 2 - Text (Basic: Dictionary and Classification)

- **Morning**
  - **Presentation:** Nicole Marie Klevanskaya, Raj Wahlquist, Sijin Chen
  - **Slides:** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day2/Day2.pdf
  - **Readings:** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day2
    - **[Practical Guide]** Barberá, P., Boydstun, A. E., Linn, S., McMahon, R., & Nagler, J. (2021). Automated text classification of news articles: A practical guide. *Political Analysis, 29*(1), 19–42. https://doi.org/10.1017/pan.2020.8 [Presentation and Discussion Lead: Nicole Marie Klevanskaya]
    - **[Overview]** Feuerriegel, S., Maarouf, A., Bär, D., Geissler, D., Schweisthal, J., Pröllochs, N., Robertson, C. E., Rathje, S., Hartmann, J., Mohammad, S. M., Netzer, O., Siegel, A. A., Plank, B., & Van Bavel, J. J. (2025). Using natural language processing to analyse text data in behavioural science. *Nature Reviews Psychology, 4*(2), 96–111. https://doi.org/10.1038/s44159-024-00392-z
    - **[Psychology]** Wang, S.-Y. N., & Inbar, Y. (2021). Moral-language use by U.S. political elites. *Psychological Science, 32*(1), 14–26. https://doi.org/10.1177/0956797620960397 [Presentation and Discussion Lead: Raj Wahlquist]
    - **[Embed NLP in a Bigger Design]** Jaidka, K., Zhou, A., & Lelkes, Y. (2019). Brevity is the soul of Twitter: The constraint affordance and political discussion. *Journal of Communication, 69*(4), 345–372. https://doi.org/10.1093/joc/jqz023 [Presentation by Sijin Chen]
    - **[Simple Study Packaged Well]** Seraj, S., Blackburn, K. G., & Pennebaker, J. W. (2021). Language left behind on social media exposes the emotional and cognitive costs of a romantic breakup. *Proceedings of the National Academy of Sciences, 118*(7), e2017154118. https://doi.org/10.1073/pnas.2017154118
- **Afternoon**
  - **Lab - Text (Basic):** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day2/Lab/Day2.md
    - **LIWC:** Tausczik, Y. R., & Pennebaker, J. W. (2010). The psychological meaning of words: LIWC and computerized text analysis methods. *Journal of Language and Social Psychology, 29*(1), 24–54. https://doi.org/10.1177/0261927X09351676
    - **Sentiment:**
      - `AFINN`, `bing`, and `nrc` in `tidytext`
    - **Classifier in R**
    - Register for **Google Perspective** which we will use at our next class: https://www.perspectiveapi.com/

### Day 3 - Text (Advanced: API, Topic Modeling, Embedding, and Innovative Use)

- **Morning**
  - **Presentation:** Jialu Fan, Jiacheng Huang, Michael Ofori
  - **Slides:** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day3/Day3.pdf
  - **Readings:** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day3
    - **[Text But Used Differently]** Toubia, O., Berger, J., & Eliashberg, J. (2021). How quantifying the shape of stories predicts their success. *Proceedings of the National Academy of Sciences, 118*(26), e2011695118. https://doi.org/10.1073/pnas.2011695118 [Presentation and Discussion Lead: Jialu Fan]
    - **[Text But Used Differently]** Zhou, A., Capizzo, L. W., Page, T. G., & Toth, E. L. (2023). Exploring public relations research topics and inter-cluster dynamics through computational modeling (2010-2020): A study based on two SSCI journals. *Journal of Public Relations Research, 35*(3), 135–161. https://doi.org/10.1080/1062726X.2023.2180373
    - **[Measuring Culture]** Kozlowski, A. C., Taddy, M., & Evans, J. A. (2019). The geometry of culture: Analyzing the meanings of class through word embeddings. *American Sociological Review, 84*(5), 905–949. https://doi.org/10.1177/0003122419877135 [Presentation and Discussion Lead: Jiacheng Huang]
    - **[Sociology and History]** Knight, C. (2022). When corporations are people: Agent talk and the development of organizational actorhood, 1890–1934. *Sociological Methods & Research, 51*(4), 1634–1680. https://doi.org/10.1177/0049124122112<<2528 [Presentation and Discussion Lead: Michael Ofori]
- **Afternoon**
  - **Lab - Text (Advanced):** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day3/Lab/Day3.md
    - **Google Perspective**: https://www.perspectiveapi.com/
    - **Topic Modeling**:
      - Roberts, M. E., Stewart, B. M., Tingley, D., Lucas, C., Leder-Luis, J., Gadarian, S. K., Albertson, B., & Rand, D. G. (2014). Structural topic models for open-ended survey responses. *American Journal of Political Science, 58*(4), 1064–1082. https://doi.org/10.1111/ajps.12103
      - Roberts, M. E., Stewart, B. M., & Tingley, D. (2019). Stm: An R package for structural topic models. *Journal of Statistical Software, 91*(2). https://doi.org/10.18637/jss.v091.i02

### Day 4 - Networks

- **Morning**
  - **Presentation:** Eunsun Kyoung, Dongwook Kim, Rita Tang
  - **Slides:** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day4/Day4.pdf
  - **Reading:** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day4
    - **[The "Network Wormhole" Study]** Park, P. S., Blumenstock, J. E., & Macy, M. W. (2018). The strength of long-range ties in population-scale social networks. *Science, 362*(6421), 1410–1413. https://doi.org/10.1126/science.aau9735
    - **[How to Make Network Description Engaging]** Schlosser, F., Maier, B. F., Jack, O., Hinrichs, D., Zachariae, A., & Brockmann, D. (2020). COVID-19 lockdown induces disease-mitigating structural changes in mobility networks. *Proceedings of the National Academy of Sciences, 117*(52), 32883–32890. https://doi.org/10.1073/pnas.2012326117 [Presentation and Discussion Lead: Eunsun Kyoung]
    - **[Create New Measures for Network Analysis]** Vosoughi, S., Roy, D., & Aral, S. (2018). The spread of true and false news online. *Science, 359*(6380), 1146–1151. https://doi.org/10.1126/science.aap9559 [Presentation and Discussion Lead: Dongwook Kim]
    - **[Projection Data]** González-Bailón, S., Lazer, D., Barberá, P., Zhang, M., Allcott, H., Brown, T., Crespo-Tenorio, A., Freelon, D., Gentzkow, M., Guess, A. M., Iyengar, S., Kim, Y. M., Malhotra, N., Moehler, D., Nyhan, B., Pan, J., Rivera, C. V., Settle, J., Thorson, E., … Tucker, J. A. (2023). Asymmetric ideological segregation in exposure to political news on Facebook. *Science, 381*(6656), 392–398. https://doi.org/10.1126/science.ade7138
    - **[Historical Sociology - Network is Everywhere]** Zhao, J., Wei, Y., & Wu, B. (2022). Analysis of the social network and the evolution of the influence of ancient Chinese poets. *Social Science Computer Review, 40*(4), 1014–1034. https://doi.org/10.1177/08944393211028182 [Presentation and Discussion Lead: Rita Tang]
- **Afternoon**
  - **Lab - Networks:** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day4/Lab/Day4.md
    - **What Networks Could Be** slides: https://github.com/alvinyxz/CSS_Workshop/blob/main/Day4/Lab/Day4_Lab.pdf
    - **ERGM**
    - **Semantic Networks**
      - Zhou, A., Liu, W., & Yang, A. (2024). Politicization of science in COVID-19 vaccine communication: Comparing US politicians, medical experts, and government agencies. *Political Communication, 41*(4), 649–671. https://doi.org/10.1080/10584609.2023.2201184
    - **Network Visualization**

### Day 5 - The Web, Computational Infrastructure, and Innovative Datasets

- **Morning**
  - **Presentation:** Jikai Sun, Jong Won Lee, Shreepriya Dogra
  - **Slides:** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day5/Day5.pdf
  - **Reading:** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day5
    - **[Sock Puppet]** Haroon, M., Wojcieszak, M., Chhabra, A., Liu, X., Mohapatra, P., & Shafiq, Z. (2023). Auditing YouTube’s recommendation system for ideologically congenial, extreme, and problematic recommendations. *Proceedings of the National Academy of Sciences, 120*(50), e2213020120. https://doi.org/10.1073/pnas.2213020120 [Presentation and Discussion Lead: Jikai Sun]
    - **[AirBnb]** Park, M., Yu, C., & Macy, M. (2023). Fighting bias with bias: How same-race endorsements reduce racial discrimination on Airbnb. *Science Advances, 9*(6), eadd2315. https://doi.org/10.1126/sciadv.add2315 [Presentation by Jong Won Lee]
    - **[User-Centric Behavioral Tracking]** Robertson, R. E., Green, J., Ruck, D. J., Ognyanova, K., Wilson, C., & Lazer, D. (2023). Users choose to engage with more partisan news than they are exposed to on Google Search. *Nature, 618*(7964), 342–348. https://doi.org/10.1038/s41586-023-06078-5 [Presentation and Discussion Lead: Shreepriya Dogra]
    - **[Overview]** Ohme, J., Araujo, T., Boeschoten, L., Freelon, D., Ram, N., Reeves, B. B., & Robinson, T. N. (2024). Digital trace data collection for social media effects research: APIs, data donation, and (screen) tracking. *Communication Methods and Measures, 18*(2), 124–141. https://doi.org/10.1080/19312458.2023.2181319
    - **[Web Browsing Data]** Clemm Von Hohenberg, B., Stier, S., Cardenal, A. S., Guess, A. M., Menchen-Trevino, E., & Wojcieszak, M. (2024). Analysis of web browsing data: A guide. *Social Science Computer Review, 42*(6), 1479–1504. https://doi.org/10.1177/08944393241227868
    - **[Industry Collaboration]** Althoff, T., Sosič, R., Hicks, J. L., King, A. C., Delp, S. L., & Leskovec, J. (2017). Large-scale physical activity data reveal worldwide activity inequality. *Nature, 547*(7663), 336–339. https://doi.org/10.1038/nature23018
    - **[Data that Companies are More Comfortable Sharing]** Zagheni, E., Weber, I., & Gummadi, K. (2017). Leveraging Facebook’s advertising platform to monitor stocks of migrants. *Population and Development Review, 43*(4), 721–734. https://doi.org/10.1111/padr.12102
- **Afternoon**
  - **Lab - The Web, Computational Infrastructure, and Innovative Datasets:** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day5/Lab/Day5.md
    - **Web Scraping**:
      - `Rvest`
      - `Selenium`
    - **Reddit API**:
      - Used to be the gold standard: https://pushshift.io/signup
      - PushShift's new successor: https://www.pullpush.io/
      - Download different dumps provided by PushShift Subreddit: https://www.reddit.com/r/pushshift/search/?q=dump&cId=1006e135-94ac-4185-ab53-ae88d0d16caa&iId=0d68e038-4a15-4658-bf63-0ba4bcd599b9
      - For example, https://github.com/ArthurHeitmann/arctic_shift/blob/master/download_links.md this link provides the download links for the Reddit comments and submissions from 2005 to 2025, basically the whole history of Reddit --- but the files are huge!
    - **YouTube API**:
      - Follow "Before you start" in https://developers.google.com/youtube/v3/getting-started
      - We will be using its Python client library: https://github.com/googleapis/google-api-python-client
    - **TikTok API**:
      - I have heard mixed success with applying for the TikTok API, but it is worth a try.
      - Apply it here https://developers.tiktok.com/docs/getting-started

### Day 6 - Image/Audio/Video

- **Morning**
  - **[Yingdan Lu](https://yingdanlu.com) Guest Lecture with Catered Lunch**
  - **Reading:** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day6
    - **[Google Map]** Gebru, T., Krause, J., Wang, Y., Chen, D., Deng, J., Aiden, E. L., & Fei-Fei, L. (2017). Using deep learning and Google Street View to estimate the demographic makeup of neighborhoods across the United States. *Proceedings of the National Academy of Sciences, 114*(50), 13108–13113. https://doi.org/10.1073/pnas.1700035114
    - **[Google Image]** Guilbeault, D., Delecourt, S., Hull, T., Desikan, B. S., Chu, M., & Nadler, E. (2024). Online images amplify gender bias. *Nature, 626*(8001), 1049–1055. https://doi.org/10.1038/s41586-024-07068-x
    - **[Book]** Adukia, A., Eble, A., Harrison, E., Runesha, H. B., & Szasz, T. (2023). What we teach about race and gender: Representation in images and text of children’s books. *The Quarterly Journal of Economics, 138*(4), 2225–2285. https://doi.org/10.1093/qje/qjad028
    - **[Music]** Negro, G., Kovács, B., & Carroll, G. R. (2022). What’s next? Artists’ music after Grammy awards. *American Sociological Review, 87*(4), 644–674. https://doi.org/10.1177/00031224221103257
    - **[Audio Tools]** Lukito, J., Greenfield, J., Yang, Y., Dahlke, R., Brown, M. A., Lewis, R., & Chen, B. (2024). Audio-as-data tools: Replicating computational data processing. *Media and Communication, 12*, 7851. https://doi.org/10.17645/mac.7851
    - **[Audio Analysis]** Dietrich, B. J., Hayes, M., & O’Brien, D. Z. (2019). Pitch perfect: Vocal pitch and the emotional intensity of congressional speech. *American Political Science Review, 113*(4), 941–962. https://doi.org/10.1017/S0003055419000467
    - **[Text, Audio, Video]** Kim, S. J., Villanueva, I. I., & Chen, K. (2024). Going beyond affective polarization: How emotions and identities are used in anti-vaccination TikTok videos. *Political Communication, 41*(4), 588–607. https://doi.org/10.1080/10584609.2023.2243852
    - **[Video]** Lu, Y., Pan, J., Xu, X., & Xu, Y. (2025). Decentralized propaganda in the era of digital media: The massive presence of the Chinese state on Douyin. *SSRN Electronic Journal*. https://doi.org/10.2139/ssrn.5145803
    - **[Video]** Legewie, N. M., & Nassauer, A. (2023). Current and future debates in video data analysis. *Sociological Methods & Research, 52*(3), 1107–1119. https://doi.org/10.1177/00491241231178275
- **Afternoon**
  - **Lab - Image/Audio/Video:** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day6/Lab/Day6.md
    - **Athec:** Peng, Y. (2022). Athec: A Python library for computational aesthetic analysis of visual media in social science research. *Computational Communication Research, 4*(1). https://doi.org/10.5117/CCR2022.1.009.PENG
    - **Face++: API Application**

### Day 7 - Looking Ahead and LLM

- **Morning**
  - **Presentation:** Gretchen Corcoran, Paulina Vergara, Jinny Zhang
  - **Slides:** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day7/Day7.pdf
  - **Reading:** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day7
    - **Computational Storytelling and the DEMM (Description-Experimentation-Mediator-Moderator) Framework**
      - **[Philosophy]** Watts, D. J. (2017). Should social science be more solution-oriented? *Nature Human Behaviour, 1*(1), 0015. https://doi.org/10.1038/s41562-016-0015
      - **[DEMM]** Lee, J. K. (2021). Emotional expressions and brand status. *Journal of Marketing Research, 58*(6), 1178–1196. https://doi.org/10.1177/00222437211037340 [Presentation and Discussion Lead: Gretchen Corcoran]
      - **[Industry Collaboration]** Yuan, Y., Liu, T. X., Tan, C., Chen, Q., Pentland, A. S., & Tang, J. (2024). Gift contagion in online groups: Evidence from virtual red packets. *Management Science, 70*(7), 4465–4479. https://doi.org/10.1287/mnsc.2023.4906
      - **[One Story, Explained To Extreme Detail]** Barari, S. (2024). Political speech from corporate America: Sparse, mostly for Democrats, and somewhat representative. *Journal of Quantitative Description: Digital Media, 4*. https://doi.org/10.51685/jqd.2024.icwsm.5
    - **Methodological Triangulation**
      - **[Computational Grounded Theory]** Nelson, L. K. (2020). Computational grounded theory: A methodological framework. *Sociological Methods & Research, 49*(1), 3–42. https://doi.org/10.1177/0049124117729703
      - **[Computational + Ethnography]** Ophir, Y., Walter, D., & Marchant, E. R. (2020). A collaborative way of knowing: Bridging computational communication research and grounded theory ethnography. *Journal of Communication, 70*(3), 447–472. https://doi.org/10.1093/joc/jqaa013
      - **[Qualitative Coding with LLMs]** Than, N., Fan, L., Law, T., Nelson, L. K., & McCall, L. (2025). Updating “the future of coding”: Qualitative coding with generative large language models. *Sociological Methods & Research*. https://doi.org/10.1177/00491241251339188
    - **Social Good**
      - **[GIS]** Yang, T., Ticona, J., & Lelkes, Y. (2021). Policing the digital divide: Institutional gate-keeping & criminalizing digital inclusion. *Journal of Communication, 71*(4), 572–597. https://doi.org/10.1093/joc/jqab019 [Presentation and Discussion Lead: Paulina Vergara]
      - **[BLM]** Wang, Y., Qin, M. S., Luo, X., & Kou, Y. (Eric). (2022). Frontiers: How support for black lives matter impacts consumer responses on social media. *Marketing Science, 41*(6), 1029–1044. https://doi.org/10.1287/mksc.2022.1372 [Presentation and Discussion Lead: Jinny Zhang]
- **Afternoon**
  - **Lab - Looking Ahead and LLM (Jiacheng Huang):** https://github.com/alvinyxz/CSS_Workshop/blob/main/Day7/Lab/
    - **LLM Text and Image Coding**
    - Lee, T. B., & Trott, S. (2023, July 27). Large language models, explained with a minimum of math and jargon. *Understanding AI*. https://www.understandingai.org/p/large-language-models-explained-with
    - Argyle, L. P., Bail, C. A., Busby, E. C., Gubler, J. R., Howe, T., Rytting, C., Sorensen, T., & Wingate, D. (2023). Leveraging AI for democratic discourse: Chat interventions can improve online political conversations at scale. *Proceedings of the National Academy of Sciences, 120*(41), e2311627120. https://doi.org/10.1073/pnas.2311627120
    - Park, J. S., O’Brien, J., Cai, C. J., Morris, M. R., Liang, P., & Bernstein, M. S. (2023). Generative agents: Interactive simulacra of human behavior. *Proceedings of the 36th Annual ACM Symposium on User Interface Software and Technology*, 1–22. https://doi.org/10.1145/3586183.3606763
    - Ashokkumar, A., Hewitt, L., Ghezae, I., & Willer, R. (2024). Predicting results of social science experiments using large language models. https://docsend.com/view/ity6yf2dansesucf

## Additional Resources

To keep the workshop content fresh, assigned readings are mostly very-recent publications. Below, I provide a list of supplementary materials and resources that may enhance your understanding of the topics covered in the workshop, many of which are considered classics in the field of computational social science.

### Day 1: CSS Overview

- Salganik, M. J. (2018). Bit by bit: Social research in the digital age. Princeton University Press.
- Grimmer, J., Roberts, M. E., & Stewart, B. M. (2022). Text as data: A new framework for machine learning and the social sciences. Princeton University Press.
- Wickham, H., Çetinkaya-Rundel, M., & Grolemund, G. (2023). R for data science: Import, tidy, transform, visualize, and model data (2nd edition). O’Reilly.
- McKinney, W. (2017). Python for data analysis: Data wrangling with Pandas, NumPy, and IPython (Second edition). O’Reilly.
- Llaudet, E., & Imai, K. (2023). Data analysis for social science: A friendly and practical introduction. Princeton University Press.
- Pearl, J., & Mackenzie, D. (2018). The book of why: The new science of cause and effect. Basic Books.
- Mohr, J., Bail, C. A., Frye, M., Lena, J. C., Lizardo, O., McDonnell, T. E., Mische, A., Tavory, I., & Wherry, F. F. (2020). Measuring culture. Columbia University Press.
- Edelmann, A., Wolff, T., Montagne, D., & Bail, C. A. (2020). Computational social science and sociology. *Annual Review of Sociology, 46*(1), 61–81. https://doi.org/10.1146/annurev-soc-121919-054621

### Day 2-3: Text

- Garg, N., Schiebinger, L., Jurafsky, D., & Zou, J. (2018). Word embeddings quantify 100 years of gender and ethnic stereotypes. *Proceedings of the National Academy of Sciences, 115*(16), E3635–E3644. https://doi.org/10.1073/pnas.1720347115
- Li, K., Mai, F., Shen, R., & Yan, X. (2021). Measuring corporate culture using machine learning. *The Review of Financial Studies, 34*(7), 3265–3315. https://doi.org/10.1093/rfs/hhaa079
- DiMaggio, P. (2015). Adapting computational text analysis to social science (and vice versa). *Big Data & Society, 2*(2), 2053951715602908. https://doi.org/10.1177/2053951715602908
- Mitts, T. (2019). From isolation to radicalization: Anti-muslim hostility and support for ISIS in the West. *American Political Science Review, 113*(1), 173–194. https://doi.org/10.1017/S0003055418000618
- Eichstaedt, J. C., Schwartz, H. A., Kern, M. L., Park, G., Labarthe, D. R., Merchant, R. M., Jha, S., Agrawal, M., Dziurzynski, L. A., Sap, M., Weeg, C., Larson, E. E., Ungar, L. H., & Seligman, M. E. P. (2015). Psychological language on Twitter predicts county-level heart disease mortality. *Psychological Science, 26*(2), 159–169. https://doi.org/10.1177/0956797614557867
- Barberá, P., Casas, A., Nagler, J., Egan, P. J., Bonneau, R., Jost, J. T., & Tucker, J. A. (2019). Who leads? Who follows? Measuring issue attention and agenda setting by legislators and the mass public using social media data. *American Political Science Review, 113*(4), 883–901. https://doi.org/10.1017/S0003055419000352

### Day 4: Networks

- Barabási, A.-L., & Albert, R. (1999). Emergence of scaling in random networks. *Science, 286*(5439), 509–512. https://doi.org/10.1126/science.286.5439.509
- Watts, D. J., & Strogatz, S. H. (1998). Collective dynamics of “small-world” networks. *Nature, 393*(6684), 440–442. https://doi.org/10.1038/30918
- Granovetter, M. S. (1973). The strength of weak ties. *American Journal of Sociology, 78*(6), 1360–1380. https://doi.org/10.1086/225469
- Rajkumar, K., Saint-Jacques, G., Bojinov, I., Brynjolfsson, E., & Aral, S. (2022). A causal test of the strength of weak ties. *Science, 377*(6612), 1304–1310. https://doi.org/10.1126/science.abl4476
- Centola, D., & Macy, M. (2007). Complex contagions and the weakness of long ties. *American Journal of Sociology, 113*(3), 702–734. https://doi.org/10.1086/521848
- Burt, R. S. (2004). Structural holes and good ideas. *American Journal of Sociology, 110*(2), 349–399. https://doi.org/10.1086/421787
- Centola, D., Becker, J., Brackbill, D., & Baronchelli, A. (2018). Experimental evidence for tipping points in social convention. *Science, 360*(6393), 1116–1119. https://doi.org/10.1126/science.aas8827
- González-Bailón, S., & Wang, N. (2016). Networked discontent: The anatomy of protest campaigns in social media. *Social Networks, 44*, 95–104. https://doi.org/10.1016/j.socnet.2015.07.003
- Clauset, A., Arbesman, S., & Larremore, D. B. (2015). Systematic inequality and hierarchy in faculty hiring networks. *Science Advances, 1*(1), e1400005. https://doi.org/10.1126/sciadv.1400005
- Kolaczyk, E. D., & Csárdi, G. (2020). Statistical analysis of network data with R. Springer.
- Lydon-Staley, D. M., Zhou, D., Blevins, A. S., Zurn, P., & Bassett, D. S. (2021). Hunters, busybodies and the knowledge network building associated with deprivation curiosity. *Nature Human Behaviour, 5*(3), 327–336. https://doi.org/10.1038/s41562-020-00985-7
- Bearman, P. S., Moody, J., & Stovel, K. (2004). Chains of affection: The structure of adolescent romantic and sexual networks. *American Journal of Sociology, 110*(1), 44–91. https://doi.org/10.1086/386272
- DellaPosta, D., Shi, Y., & Macy, M. (2015). Why do liberals drink lattes? *American Journal of Sociology, 120*(5), 1473–1511. https://doi.org/10.1086/681254
- Shi, F., Shi, Y., Dokshin, F. A., Evans, J. A., & Macy, M. W. (2017). Millions of online book co-purchases reveal partisan differences in the consumption of science. *Nature Human Behaviour, 1*(4), 0079. https://doi.org/10.1038/s41562-017-0079

### Day 5: The Web, Computational Infrastructure, and Public Datasets

- Guess, A. M., Nyhan, B., & Reifler, J. (2020). Exposure to untrustworthy websites in the 2016 US election. *Nature Human Behaviour, 4*(5), 472–480. https://doi.org/10.1038/s41562-020-0833-x
- King, G., Pan, J., & Roberts, M. E. (2013). How censorship in China allows government criticism but silences collective expression. *American Political Science Review, 107*(2), 326–343. https://doi.org/10.1017/S0003055413000014
- Yang, T., & Peng, Y. (2022). The importance of trending topics in the gatekeeping of social media news engagement: A natural experiment on Weibo. *Communication Research, 49*(7), 994–1015. https://doi.org/10.1177/0093650220933729
- Freelon, D. (2018). Computational research in the post-API age. *Political Communication, 35*(4), 665–668. https://doi.org/10.1080/10584609.2018.1477506
- Zhou, A., Metaxa, D., Kim, Y. M., & Jaidka, K. (2024). User-centric behavioral tracking: Lessons from three case studies with do-it-yourself computational pipelines. *Journal of Advertising, 53*(5), 791–809. https://doi.org/10.1080/00913367.2024.2403613

### Day 6: Images/Videos/Audio

- Peng, Y. (2018). Same candidates, different faces: Uncovering media bias in visual portrayals of presidential candidates with computer vision. *Journal of Communication, 68*(5), 920–941. https://doi.org/10.1093/joc/jqy041
- Zhang, H., & Peng, Y. (2024). Image clustering: An unsupervised approach to categorize visual data in social science research. *Sociological Methods & Research, 53*(3), 1534–1587. https://doi.org/10.1177/00491241221082603
- Askin, N., & Mauskapf, M. (2017). What makes popular culture popular? Product features and optimal differentiation in music. *American Sociological Review, 82*(5), 910–944. https://doi.org/10.1177/0003122417728662
- Jean, N., Burke, M., Xie, M., Davis, W. M., Lobell, D. B., & Ermon, S. (2016). Combining satellite imagery and machine learning to predict poverty. *Science, 353*(6301), 790–794. https://doi.org/10.1126/science.aaf7894
- Joo, J., & Steinert-Threlkeld, Z. C. (2022). Image as data: Automated content analysis for visual presentations of political actors and events. *Computational Communication Research, 4*(1). https://doi.org/10.5117/CCR2022.1.001.JOO
- Stephens, K. K., Waller, M. J., & Sohrab, S. G. (2019). Over-emoting and perceptions of sincerity: Effects of nuanced displays of emotions and chosen words on credibility perceptions during a crisis. *Public Relations Review, 45*(5), 101841. https://doi.org/10.1016/j.pubrev.2019.101841

### Day 7: Looking Ahead and LLM

- Bail, C. A. (2016). Combining natural language processing and network analysis to examine how advocacy organizations stimulate conversation on social media. *Proceedings of the National Academy of Sciences, 113*(42), 11823–11828. https://doi.org/10.1073/pnas.1607151113
- Ludwig, J., & Mullainathan, S. (2024). Machine learning as a tool for hypothesis generation. *The Quarterly Journal of Economics, 139*(2), 751–827. https://doi.org/10.1093/qje/qjad055
- Bail, C. A. (2024). Can generative AI improve social science? *Proceedings of the National Academy of Sciences, 121*(21), e2314021121. https://doi.org/10.1073/pnas.2314021121
- Gilardi, F., Alizadeh, M., & Kubli, M. (2023). ChatGPT outperforms crowd workers for text-annotation tasks. *Proceedings of the National Academy of Sciences, 120*(30), e2305016120. https://doi.org/10.1073/pnas.2305016120
- Rathje, S., Mirea, D.-M., Sucholutsky, I., Marjieh, R., Robertson, C. E., & Van Bavel, J. J. (2024). GPT is an effective tool for multilingual psychological text analysis. *Proceedings of the National Academy of Sciences, 121*(34), e2308950121. https://doi.org/10.1073/pnas.2308950121
