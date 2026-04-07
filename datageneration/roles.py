import random
import pandas as pd
from tqdm import tqdm
from faker import Faker
from pathlib import Path

TABLES = Path(__file__).resolve().parent.parent / "tables"
TABLES.mkdir(parents=True, exist_ok=True)

faker = Faker()

ROW_COUNT = 200000

# load existing CSVs
moviesDf = pd.read_csv(TABLES / "movies.csv")
actorsDf = pd.read_csv(TABLES / "actors.csv")

# precompute eligible actors per unique release year
# an actor must be born at least 6 years before the movie's release year
uniqueReleaseYears = moviesDf["releaseDate"].unique()
yearToEligibleActors = {}
for year in tqdm(uniqueReleaseYears, desc="Precomputing eligible actors per year"):
    eligible = actorsDf[actorsDf["birthYear"] <= year - 6]["actorID"].tolist()
    if not eligible:
        # fallback: use the oldest available actor(s)
        eligible = actorsDf.nsmallest(1, "birthYear")["actorID"].tolist()
    yearToEligibleActors[year] = eligible

# map each movieID to its eligible actor list
movieIdList = moviesDf["movieID"].tolist()
movieReleaseYearMap = dict(zip(moviesDf["movieID"], moviesDf["releaseDate"]))
movieEligibleActors = {mid: yearToEligibleActors[movieReleaseYearMap[mid]] for mid in movieIdList}

# build reverse mapping: actorID → eligible movieIDs
# needed to seed exactly one role for every actor in phase 1
actorBirthYearMap = dict(zip(actorsDf["actorID"], actorsDf["birthYear"]))
actorEligibleMovies = {}
for aid, byear in tqdm(actorBirthYearMap.items(), desc="Precomputing eligible movies per actor"):
    eligible = moviesDf.loc[moviesDf["releaseDate"] >= byear + 6, "movieID"].tolist()
    if not eligible:
        eligible = moviesDf.nlargest(1, "releaseDate")["movieID"].tolist()
    actorEligibleMovies[aid] = eligible

allActorIds = actorsDf["actorID"].tolist()

def generateRoleName():
    return faker.first_name() if random.random() < 0.5 else faker.name()

roleNames = []
roleMovieIds = []
roleActorIds = []
usedTriplets = set()

# phase 1: guarantee every actor appears in at least one role
with tqdm(total=len(allActorIds), desc="Phase 1 — seeding one role per actor") as pbar:
    for actorId in allActorIds:
        while True:
            movieId = random.choice(actorEligibleMovies[actorId])
            roleName = generateRoleName()
            triplet = (movieId, actorId, roleName)
            if triplet not in usedTriplets:
                usedTriplets.add(triplet)
                roleMovieIds.append(movieId)
                roleActorIds.append(actorId)
                roleNames.append(roleName)
                pbar.update(1)
                break

# phase 2: fill the remaining rows with random roles
with tqdm(total=ROW_COUNT - len(allActorIds), desc="Phase 2 — filling remaining roles") as pbar:
    while len(roleMovieIds) < ROW_COUNT:
        movieId = random.choice(movieIdList)
        actorId = random.choice(movieEligibleActors[movieId])
        roleName = generateRoleName()
        triplet = (movieId, actorId, roleName)
        if triplet in usedTriplets:
            continue
        usedTriplets.add(triplet)
        roleMovieIds.append(movieId)
        roleActorIds.append(actorId)
        roleNames.append(roleName)
        pbar.update(1)

# build and save the dataframe
df = pd.DataFrame({
    "movieID": roleMovieIds,
    "actorID": roleActorIds,
    "roleName": roleNames
})

df.to_csv(TABLES / "roles.csv", index=False)
print(f"roles.csv saved with {len(df):,} rows.")