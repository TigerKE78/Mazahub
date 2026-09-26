# Mazahub

## Load / วิธีรัน

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/TigerKE78/Mazahub/main/maza.luau"))()
```

The loader downloads and executes the current `main/maza.luau`. Review the source before running it. Requires an environment providing `game:HttpGet` and `loadstring`.

คำสั่งนี้ดาวน์โหลดและรันไฟล์ `maza.luau` เวอร์ชันปัจจุบันจากสาขา `main` ควรอ่านโค้ดก่อนใช้งาน และต้องใช้สภาพแวดล้อมที่รองรับ `game:HttpGet` กับ `loadstring`

## Updates / อัปเดต

Update `maza.luau` on `main`; the loader URL stays the same. Existing sessions need to run the loader again to receive updates. GitHub caching may delay availability briefly.

แก้ไฟล์ `maza.luau` บน `main` แล้วใช้คำสั่งเดิมได้ รันใหม่เพื่อรับเวอร์ชันล่าสุด โดยแคชของ GitHub อาจทำให้การอัปเดตช้าชั่วคราว
