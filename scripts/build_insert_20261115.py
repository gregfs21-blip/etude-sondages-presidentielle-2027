# Génère db/insert_20261115_rattrapage.sql à partir des chiffres relevés
# directement dans les PDF instituts / notices commission des sondages
# (session du 15 novembre 2026, utilisateur présent).
# Règles : une figure principale par bloc et par scénario.
#   rn     : Le Pen (ou Bardella)
#   centre : Philippe s'il est testé, sinon Attal, sinon Lagarde ; les autres
#            figures du centre du même scénario ne sont PAS saisies
#   lfi    : Mélenchon
#   gauche : Glucksmann uniquement
#   droite : Retailleau uniquement
#   autres : tous les autres candidats, une ligne chacun
# "<1 %" est saisi 0,5.

CENTRE_ORDER = ["Philippe", "Attal", "Lagarde"]
DROP_IF_SECONDARY_CENTRE = {"Philippe", "Attal", "Lagarde"}
FIXED = {"Le Pen": "rn", "Bardella": "rn", "Mélenchon": "lfi",
         "Glucksmann": "gauche", "Retailleau": "droite"}

POLLS = []

def poll(key, pollster, sponsor, fs, fe, pub, n, url, notes, hyps):
    POLLS.append(dict(key=key, pollster=pollster, sponsor=sponsor, fs=fs, fe=fe,
                      pub=pub, n=n, url=url, notes=notes, hyps=hyps))

# 1. Elabe / BFMTV-La Tribune Dimanche, 14-16 oct., notice 10324
poll("13329-les-francais", "Elabe", "BFMTV / La Tribune Dimanche", "2026-10-14", "2026-10-16", "2026-10-17", 1553,
     "https://elabe.fr/fichier-pdf/13329-les-francais-et-lelection-presidentielle-2027/",
     "Elabe pour BFMTV / La Tribune Dimanche (notice commission 10324). PDF institut vérifié le 15 nov. 2026 (utilisateur présent). 6 configurations, chacune = 100. 1 553 inscrits sur 1 701.",
     {"C1": {"Arthaud":1,"Roussel":1.5,"Mélenchon":15,"Tondelier":3,"Glucksmann":15.5,"Philippe":16.5,"Villepin":2,"Retailleau":7,"Dupont-Aignan":2.5,"Le Pen":32.5,"Zemmour":3.5},
      "C2": {"Arthaud":1,"Roussel":2,"Mélenchon":16,"Tondelier":2.5,"Glucksmann":16.5,"Attal":10.5,"Villepin":3,"Retailleau":9.5,"Dupont-Aignan":2,"Le Pen":33.5,"Zemmour":3.5},
      "C3": {"Arthaud":0.5,"Roussel":1.5,"Mélenchon":15.5,"Tondelier":2.5,"Glucksmann":15,"Philippe":15.5,"Retailleau":6.5,"Lisnard":5.5,"Dupont-Aignan":3,"Le Pen":31.5,"Zemmour":3},
      "C4": {"Arthaud":1,"Roussel":1.5,"Mélenchon":16,"Glucksmann":16.5,"Attal":9.5,"Retailleau":9,"Lisnard":6.5,"Dupont-Aignan":2.5,"Ruffin":3,"Le Pen":31,"Zemmour":3.5},
      "C5": {"Arthaud":0.5,"Roussel":1.5,"Mélenchon":15.5,"Tondelier":2.5,"Glucksmann":15.5,"Philippe":13.5,"Attal":4.5,"Retailleau":7.5,"Dupont-Aignan":3,"Le Pen":32.5,"Zemmour":3.5},
      "C6": {"Arthaud":1,"Roussel":1,"Mélenchon":15,"Tondelier":2.5,"Glucksmann":16,"Philippe":16.5,"Retailleau":7.5,"Dupont-Aignan":2.5,"Polony":1.5,"Le Pen":33.5,"Zemmour":3}})

# 2. OpinionWay / CNews, 13-14 oct., notice 10319
poll("10319-pres-iv-opinionway", "OpinionWay", "CNews", "2026-10-13", "2026-10-14", "2026-10-15", 978,
     "https://www.commission-des-sondages.fr/notices/files/notices/2026/octobre/10319-pres-iv-opinionway-cnews-15-octobre.pdf",
     "Notice commission 10319, vérifiée le 15 nov. 2026. 1 hypothèse. 978 inscrits sur 1 043. Bouamrane <1 % saisi 0,5.",
     {"H": {"Arthaud":1,"Mélenchon":15,"Roussel":1,"Tondelier":2,"Glucksmann":13,"Bouamrane":0.5,"Attal":5,"Philippe":12,"Retailleau":6,"Lisnard":4,"Dupont-Aignan":1,"Zemmour":5,"Le Pen":35}})

# 3. YouGov / Le HuffPost, 12-15 oct., notice 10323 (scores pondérés)
poll("10323-pres-iv-yougov", "YouGov", "Le HuffPost", "2026-10-12", "2026-10-15", "2026-10-18", 976,
     "https://www.commission-des-sondages.fr/notices/files/notices/2026/octobre/10323-pres-iv-yougov-le-huffpost-18-octobre.pdf",
     "Notice commission 10323, vérifiée le 15 nov. 2026. 5 hypothèses, scores pondérés (sommes 99-101 par arrondi). 976 inscrits sur 1 094. H4 : Hollande remplace Glucksmann -> autres, pas de ligne gauche.",
     {"H1": {"Retailleau":6,"Philippe":10,"Zemmour":3,"Roussel":3,"Attal":6,"Mélenchon":15,"Le Pen":36,"Tondelier":6,"Arthaud":0,"Dupont-Aignan":3,"Glucksmann":12},
      "H2": {"Retailleau":9,"Zemmour":4,"Roussel":3,"Attal":10,"Mélenchon":15,"Le Pen":37,"Tondelier":6,"Arthaud":0,"Dupont-Aignan":3,"Glucksmann":14},
      "H3": {"Retailleau":7,"Philippe":13,"Zemmour":3,"Roussel":3,"Mélenchon":15,"Le Pen":36,"Tondelier":6,"Arthaud":0,"Dupont-Aignan":3,"Glucksmann":13},
      "H4": {"Retailleau":7,"Philippe":15,"Zemmour":4,"Roussel":3,"Mélenchon":16,"Le Pen":37,"Tondelier":6,"Arthaud":1,"Dupont-Aignan":3,"Hollande":9},
      "H5": {"Retailleau":5,"Philippe":8,"Zemmour":4,"Roussel":2,"Attal":6,"Mélenchon":13,"Le Pen":35,"Tondelier":5,"Arthaud":0,"Dupont-Aignan":2,"Glucksmann":12,"Lisnard":4,"Villepin":1,"Ruffin":2}})

# 4. Toluna Harris Interactive / M6-RTL, vague 8, 19-21 oct., notice 10332
poll("10332-pres-iv-toluna", "Toluna", "M6 / RTL", "2026-10-19", "2026-10-21", "2026-10-23", 2094,
     "https://www.commission-des-sondages.fr/notices/files/notices/2026/octobre/10332-pres-iv-toluna-harris-interactive-23-octobre.pdf",
     "Vague 8, notice commission 10332, vérifiée le 15 nov. 2026. 5 hypothèses = 100. 2 094 inscrits sur 2 500.",
     {"H1": {"Arthaud":1,"Mélenchon":17,"Roussel":2,"Tondelier":2,"Glucksmann":12,"Philippe":15,"Villepin":1,"Lisnard":7,"Retailleau":4,"Dupont-Aignan":1,"Le Pen":33,"Zemmour":5},
      "H2": {"Arthaud":1,"Mélenchon":17,"Roussel":2,"Tondelier":2,"Glucksmann":14,"Attal":10,"Villepin":2,"Lisnard":8,"Retailleau":5,"Dupont-Aignan":1,"Le Pen":33,"Zemmour":5},
      "H3": {"Arthaud":1,"Mélenchon":17,"Roussel":1,"Tondelier":2,"Glucksmann":12,"Attal":5,"Philippe":13,"Retailleau":6,"Dupont-Aignan":2,"Le Pen":35,"Zemmour":6},
      "H4": {"Arthaud":1,"Mélenchon":17,"Roussel":2,"Tondelier":2,"Glucksmann":13,"Philippe":16,"Retailleau":7,"Dupont-Aignan":2,"Le Pen":35,"Zemmour":5},
      "H5": {"Arthaud":1,"Mélenchon":19,"Roussel":2,"Tondelier":2,"Glucksmann":13,"Attal":11,"Retailleau":9,"Dupont-Aignan":2,"Le Pen":35,"Zemmour":6}})

# 5. OpinionWay / CNews, 21-22 oct., notice 10333
poll("CNEWS-Les-intentions-de-vote-a-lelection-presidentielle-2027-22-octobre", "OpinionWay", "CNews", "2026-10-21", "2026-10-22", "2026-10-22", 973,
     "https://www.opinion-way.com/wp-content/uploads/2026/10/OpinionWay-pour-CNEWS-Les-intentions-de-vote-a-lelection-presidentielle-2027-22-octobre-2026-1.pdf",
     "OpinionWay pour CNews, vague 3 (notice commission 10333). PDF institut vérifié le 15 nov. 2026. 1 hypothèse. 973 inscrits sur 1 033. Arthaud et Bouamrane <1 % saisis 0,5.",
     {"H": {"Arthaud":0.5,"Mélenchon":16,"Roussel":1,"Tondelier":1,"Glucksmann":13,"Bouamrane":0.5,"Attal":4,"Philippe":12,"Retailleau":6,"Lisnard":6,"Dupont-Aignan":1,"Zemmour":4,"Le Pen":36}})

# 6. Ipsos BVA / CESI / Le Parisien, 21-22 oct., notice 10338
poll("10338-pres-iv-ipsos-bva", "Ipsos", "Le Parisien (Ipsos bva / CESI)", "2026-10-21", "2026-10-22", "2026-10-24", 1500,
     "https://www.commission-des-sondages.fr/notices/files/notices/2026/octobre/10338-pres-iv-ipsos-bva-le-parisien-24-octobre.pdf",
     "Notice commission 10338, vérifiée le 15 nov. 2026. 4 hypothèses = 100. En B et C, Bardella testé à la place de Le Pen (même bloc RN).",
     {"A": {"Arthaud":0.5,"Mélenchon":17,"Roussel":2,"Tondelier":3.5,"Glucksmann":13,"Attal":4,"Philippe":13,"Retailleau":7.5,"Dupont-Aignan":1.5,"Le Pen":33.5,"Zemmour":4.5},
      "B": {"Arthaud":0.5,"Mélenchon":17,"Roussel":2,"Tondelier":3.5,"Glucksmann":14,"Philippe":15,"Retailleau":8,"Dupont-Aignan":2,"Bardella":33.5,"Zemmour":4.5},
      "C": {"Arthaud":0.5,"Mélenchon":17,"Roussel":2.5,"Tondelier":3.5,"Glucksmann":15.5,"Attal":9.5,"Retailleau":11.5,"Dupont-Aignan":2,"Bardella":33.5,"Zemmour":4.5},
      "D": {"Arthaud":0.5,"Mélenchon":17,"Roussel":2.5,"Tondelier":3.5,"Glucksmann":13,"Philippe":14,"Retailleau":5.5,"Lisnard":6.5,"Dupont-Aignan":1.5,"Le Pen":32,"Zemmour":4}})

# 7. IFOP / LCI, 27-29 oct., notice 10351 (publiée d'abord sous le n° 10352)
poll("10352-pres-iv-ifop-lci", "IFOP", "LCI", "2026-10-27", "2026-10-29", "2026-11-03", 1501,
     "https://www.commission-des-sondages.fr/notices/files/notices/2026/novembre/10352-pres-iv-ifop-lci-3-novembre.pdf",
     "IFOP pour LCI (fiche FD 122887). Notice commission 10351 ; le même PDF a d'abord été publié sous le n° 10352 (contenu identique selon MieuxVoter/presidentielle2027 #339). Vérifié le 15 nov. 2026. 4 scénarios = 100. 1 501 inscrits sur 1 650.",
     {"S1": {"Arthaud":0.5,"Mélenchon":18,"Roussel":2,"Tondelier":3,"Glucksmann":10,"Attal":5,"Philippe":9.5,"Retailleau":4,"Lisnard":7,"Dupont-Aignan":1.5,"Le Pen":35,"Zemmour":4.5},
      "S2": {"Arthaud":0.5,"Mélenchon":17.5,"Roussel":2,"Tondelier":3,"Glucksmann":13,"Attal":9,"Retailleau":5,"Lisnard":7.5,"Dupont-Aignan":2,"Le Pen":36,"Zemmour":4.5},
      "S3": {"Arthaud":1,"Mélenchon":17.5,"Roussel":1.5,"Tondelier":3.5,"Glucksmann":11.5,"Philippe":15,"Retailleau":7,"Dupont-Aignan":2,"Le Pen":37,"Zemmour":4},
      "S4": {"Arthaud":0.5,"Mélenchon":17.5,"Roussel":2,"Tondelier":3,"Glucksmann":11,"Philippe":15,"Lisnard":9,"Dupont-Aignan":2,"Le Pen":36,"Zemmour":4}})

# 8. Toluna Harris Interactive / M6-RTL, vague 9, 3-5 nov., notice 10362
poll("10362-pres-iv-toluna", "Toluna", "M6 / RTL", "2026-11-03", "2026-11-05", "2026-11-09", 2101,
     "https://www.commission-des-sondages.fr/notices/files/notices/2026/novembre/10362-pres-iv-toluna-harris-interactive-9-novembre.pdf",
     "Vague 9, notice commission 10362, vérifiée le 15 nov. 2026 (et PDF tolunacorporate.com). 5 hypothèses = 100. Correspondance noms/chiffres reconstituée par l'ordre de la liste (même ordre que la vague 8, où elle est explicite) et cohérente avec les autres instituts. 2 101 inscrits sur 2 436.",
     {"H1": {"Arthaud":1,"Mélenchon":19,"Roussel":1,"Tondelier":2,"Glucksmann":11,"Philippe":12,"Villepin":2,"Lisnard":9,"Retailleau":5,"Dupont-Aignan":1,"Le Pen":34,"Zemmour":3},
      "H2": {"Arthaud":1,"Mélenchon":19,"Roussel":1,"Tondelier":2,"Glucksmann":12,"Attal":9,"Villepin":2,"Lisnard":9,"Retailleau":6,"Dupont-Aignan":1,"Le Pen":35,"Zemmour":3},
      "H3": {"Arthaud":1,"Mélenchon":18,"Roussel":2,"Tondelier":2,"Glucksmann":11,"Attal":6,"Philippe":11,"Retailleau":7,"Dupont-Aignan":2,"Le Pen":36,"Zemmour":4},
      "H4": {"Arthaud":1,"Mélenchon":19,"Roussel":2,"Tondelier":2,"Glucksmann":12,"Philippe":14,"Retailleau":8,"Dupont-Aignan":2,"Le Pen":36,"Zemmour":4},
      "H5": {"Arthaud":1,"Mélenchon":19,"Roussel":2,"Tondelier":3,"Glucksmann":13,"Attal":10,"Retailleau":10,"Dupont-Aignan":2,"Le Pen":36,"Zemmour":4}})

# 9. Cluster17 / Politico, 9-10 nov., notice 10368
poll("Sondage_Cluster17_ITV_P2027-Politico", "Cluster17", "Politico", "2026-11-09", "2026-11-10", "2026-11-11", 1164,
     "https://cluster17.com/wp-content/uploads/2026/11/Sondage_Cluster17_ITV_P2027-Politico.pdf",
     "Cluster17 pour Politico (notice commission 10368). PDF institut vérifié le 15 nov. 2026, tableau récapitulatif explicite. 4 hypothèses = 100. 1 164 inscrits sur 1 242. H3 : Lagarde seule au centre -> centre. H4 (18 candidats) : Philippe (8) retenu au centre, Lagarde (8) et Attal (2) non saisis ; Riner, Polony, Villepin, Ruffin, Asselineau -> autres.",
     {"H1": {"Arthaud":0.5,"Mélenchon":20,"Roussel":2,"Tondelier":1.5,"Glucksmann":11,"Philippe":13.5,"Lisnard":10,"Retailleau":5,"Dupont-Aignan":3,"Le Pen":30.5,"Zemmour":3},
      "H2": {"Arthaud":0.5,"Mélenchon":20.5,"Roussel":2,"Tondelier":1.5,"Glucksmann":11.5,"Attal":11,"Lisnard":10,"Retailleau":6,"Dupont-Aignan":3,"Le Pen":31,"Zemmour":3},
      "H3": {"Arthaud":0.5,"Mélenchon":20.5,"Roussel":2.5,"Tondelier":1.5,"Glucksmann":10,"Lagarde":14,"Lisnard":10,"Retailleau":5.5,"Dupont-Aignan":2,"Le Pen":30.5,"Zemmour":3},
      "H4": {"Arthaud":0.5,"Mélenchon":19,"Ruffin":1.5,"Roussel":1.5,"Tondelier":1,"Glucksmann":8,"Villepin":1,"Philippe":8,"Attal":2,"Lagarde":8,"Polony":2.5,"Riner":2,"Lisnard":8,"Retailleau":5,"Asselineau":1,"Dupont-Aignan":2,"Le Pen":27,"Zemmour":2}})

# 10. OpinionWay / Les Echos - Radio Classique, Présitrack vague 4, 9-10 nov.
poll("Barometre-Presitrack-2027-Vague-4", "OpinionWay", "Les Echos / Radio Classique", "2026-11-09", "2026-11-10", "2026-11-11", 982,
     "https://www.opinion-way.com/wp-content/uploads/2026/11/OpinionWay-pour-Les-Echos-et-Radio-Classique-Barometre-Presitrack-2027-Vague-4-Novembre-2026.pdf",
     "Présitrack 2027 vague 4. PDF institut vérifié le 15 nov. 2026, tableaux explicites. 3 hypothèses = 100. 982 inscrits sur 1 017. Date de publication exacte non relevée (terrain 9-10 nov.) : 11 nov. retenu par défaut.",
     {"H1": {"Le Pen":34,"Mélenchon":17,"Glucksmann":11,"Attal":4,"Philippe":11,"Lisnard":10,"Retailleau":4,"Tondelier":3,"Zemmour":3,"Roussel":1,"Dupont-Aignan":1,"Arthaud":1},
      "H2": {"Le Pen":34,"Mélenchon":16,"Glucksmann":13,"Attal":10,"Lisnard":12,"Retailleau":6,"Tondelier":3,"Zemmour":3,"Roussel":1,"Dupont-Aignan":1,"Arthaud":1},
      "H3": {"Le Pen":34,"Mélenchon":16,"Glucksmann":12,"Philippe":12,"Lisnard":11,"Retailleau":4,"Tondelier":3,"Zemmour":3,"Roussel":2,"Dupont-Aignan":2,"Arthaud":1}})

# 11. Elabe / BFMTV-La Tribune Dimanche, 12-13 nov.
poll("13399-les-francais", "Elabe", "BFMTV / La Tribune Dimanche", "2026-11-12", "2026-11-13", "2026-11-14", 1391,
     "https://elabe.fr/fichier-pdf/13399-les-francais-et-lelection-presidentielle-2027/",
     "Elabe pour BFMTV / La Tribune Dimanche. PDF institut vérifié le 15 nov. 2026, tableau récapitulatif explicite. 6 configurations = 100. 1 391 inscrits sur 1 500. C6 : Riner, Polony -> autres.",
     {"C1": {"Arthaud":0.5,"Roussel":2,"Mélenchon":17,"Tondelier":3,"Glucksmann":13.5,"Philippe":15,"Villepin":2.5,"Retailleau":6,"Dupont-Aignan":3,"Le Pen":33,"Zemmour":4.5},
      "C2": {"Arthaud":1,"Roussel":2.5,"Mélenchon":17.5,"Tondelier":3,"Glucksmann":14,"Villepin":3,"Attal":10,"Retailleau":9,"Dupont-Aignan":2.5,"Le Pen":33,"Zemmour":4.5},
      "C3": {"Arthaud":0.5,"Roussel":2,"Mélenchon":17.5,"Tondelier":3.5,"Glucksmann":13,"Philippe":12,"Attal":5.5,"Retailleau":6,"Dupont-Aignan":3,"Le Pen":33,"Zemmour":4},
      "C4": {"Arthaud":0.5,"Roussel":1.5,"Mélenchon":17.5,"Ruffin":3,"Glucksmann":14,"Attal":8.5,"Retailleau":6,"Lisnard":10.5,"Dupont-Aignan":2.5,"Le Pen":32,"Zemmour":4},
      "C5": {"Arthaud":0.5,"Roussel":2.5,"Mélenchon":18.5,"Glucksmann":13.5,"Philippe":13,"Retailleau":4,"Lisnard":9,"Dupont-Aignan":3,"Le Pen":32.5,"Zemmour":3.5},
      "C6": {"Arthaud":0.5,"Roussel":1.5,"Mélenchon":17,"Tondelier":3,"Glucksmann":10.5,"Polony":1.5,"Riner":4.5,"Philippe":9.5,"Attal":4,"Retailleau":4,"Lisnard":8,"Dupont-Aignan":2,"Le Pen":31,"Zemmour":3}})


def q(s):
    return "'" + s.replace("'", "''") + "'"

out = ["-- Rattrapage du 15 novembre 2026 (session avec utilisateur présent).",
       "-- Généré par scripts/build_insert_20261115.py : 11 sondages vérifiés sur PDF",
       "-- institut ou notice commission des sondages. Voir claude/suivi-sondages-2027.md.",
       "begin;",
       "insert into pollsters (name, notes) select 'YouGov', null where not exists (select 1 from pollsters where name='YouGov');",
       "insert into pollsters (name, notes) select 'Elabe', 'Sondages bruts Elabe (distinct de l''agrégat EPOC Info)' where not exists (select 1 from pollsters where name='Elabe');"]
problems = []
total_rows = 0
for p in POLLS:
    out.append(f"\n-- {p['pollster']} / {p['sponsor']}, terrain {p['fs']} -> {p['fe']}")
    out.append("insert into polls (pollster_id, sponsor, field_start, field_end, published_date, sample_size, poll_type, source_url, notes) values (")
    out.append(f"  (select id from pollsters where name = {q(p['pollster'])}), {q(p['sponsor'])}, '{p['fs']}', '{p['fe']}', '{p['pub']}', {p['n']}, 'raw',")
    out.append(f"  {q(p['url'])},")
    out.append(f"  {q(p['notes'])});")
    rows = []
    for h, cands in p["hyps"].items():
        s = sum(cands.values())
        if abs(s - 100) > 2.01:
            problems.append(f"{p['key']} {h} somme={s}")
        centre = next((c for c in CENTRE_ORDER if c in cands), None)
        for c, v in cands.items():
            if c in FIXED:
                bloc = FIXED[c]
            elif c in DROP_IF_SECONDARY_CENTRE:
                if c != centre:
                    continue
                bloc = "centre"
            else:
                bloc = "autres"
            rows.append(f"select id, '{bloc}', {q(c + ' (' + h + ')')}, {v}, {v}, {v} from polls where source_url = {q(p['url'])}")
    out.append("insert into poll_results (poll_id, bloc_id, candidate_label, low_pct, high_pct, point_pct)")
    out.append("\nunion all ".join(rows) + ";")
    total_rows += len(rows)
out.append("\ncommit;")
open("db/insert_20261115_rattrapage.sql", "w", encoding="utf-8").write("\n".join(out) + "\n")
print("polls:", len(POLLS), "rows:", total_rows)
print("problèmes de somme:", problems or "aucun")
