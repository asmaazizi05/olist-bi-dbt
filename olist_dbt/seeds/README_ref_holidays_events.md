# ref_holidays_events

- **Contenu** : jours fériés nationaux brésiliens et événements commerciaux, 2016-2018 (une ligne par date).
- **Source** : calendrier officiel des jours fériés fédéraux brésiliens (lois 662/1949 et 10.607/2002) ; dates des événements commerciaux (Black Friday = lendemain de Thanksgiving, Dia das Mães = 2e dimanche de mai, Dia dos Pais = 2e dimanche d'août, etc.).
- **Licence** : faits de calendrier compilés manuellement par l'équipe, pas de jeu de données tiers redistribué.
- **Date de récupération** : 18 novembre 2026.
- **Transformations** : saisie manuelle, une seule ligne par date (la fête des enfants du 12 octobre est fusionnée avec Nossa Senhora Aparecida). Jours fériés mobiles calculés à partir de Pâques (2016-03-27, 2017-04-16, 2018-04-01).
- **À vérifier** par l'équipe avant la soutenance, par exemple sur un calendrier officiel.
- **Utilisation** : jointure dans `dim_date` pour analyser la saisonnalité.
