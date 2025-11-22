from fastapi import FastAPI, HTTPException


app = FastAPI()

text_posts = {
    1: {
        "title": "Monday Motivation",
        "content": "Start your week strong! Remember, the only bad workout is the one that didn't happen. #MondayBlues #Hustle"
    },
    2: {
        "title": "Coffee Break",
        "content": "Is it really a morning if you haven't had your second cup of coffee yet? asking for a friend. ☕"
    },
    3: {
        "title": "Tech Update",
        "content": "Just installed the latest Python version. The new features are looking crisp! Can't wait to refactor my old scripts."
    },
    4: {
        "title": "Lunch Time",
        "content": "Tried that new burger place downtown. 10/10 would recommend. The fries were life-changing. 🍔🍟"
    },
    5: {
        "title": "Throwback Thursday",
        "content": "Missing the beach vibes from last summer. Take me back to the ocean! 🌊☀️ #TBT #VacationMode"
    },
    6: {
        "title": "DIY Weekend",
        "content": "Finally painted the living room! It only took three coats and a lot of patience, but it looks amazing."
    },
    7: {
        "title": "Pet Appreciation",
        "content": "My dog looked at me for 5 minutes straight until I gave him a treat. He knows who runs this house. 🐶"
    },
    8: {
        "title": "Night Owl",
        "content": "Why does my best coding happen at 2 AM? My sleep schedule is crying, but my GitHub contributions are green."
    },
    9: {
        "title": "Book Club",
        "content": "Just finished reading 'The Midnight Library'. Such a mind-bending concept! What should I read next? 📚"
    },
    10: {
        "title": "Sunday Reset",
        "content": "Groceries done, laundry folded, meal prep sorted. Ready to conquer the upcoming week! ✨"
    }
}

@app.get("/posts")
def get_text_posts(limit: int):
    if limit:
        return list(text_posts.values())[:limit]
    return text_posts

@app.get("/posets/{id}")
def get_post(id: int):
    if id not in text_posts:
        raise HTTPException(status_code=404, detail="Post not found")
    return text_posts.get(id)


@app.post("/posts")
def create_post():
    pass