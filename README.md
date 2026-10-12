# ShortGPT — bộ cài cho máy khách hàng

Thư mục này là tất cả những gì cần mang sang máy khác. Không cần mã nguồn, không
cần Git, không cần Python: app nằm trong image trên ghcr, `install.sh` lo phần
còn lại.

```
install.sh          cài đặt — Windows (Git Bash) và macOS
docker-compose.yml  ba container: app, AutoReel Engine (api + web ui)
open-chrome.bat     mở cửa sổ Chrome để đăng nhập Shopee  (Windows)
open-chrome.sh      như trên                              (macOS)
start.bat / start.sh    khởi động app + mở giao diện
stop.bat  / stop.sh     tắt app (dữ liệu trong ./data giữ nguyên)
.env.example        bản mẫu cấu hình (install.sh chép thành .env)
HUONG-DAN-FACEBOOK.md   nối Facebook từng bước (chỉ khi đăng bài lên Page)
data/               toàn bộ dữ liệu: video, database, log, model (tự sinh ra)

Cài đặt.command          nhấp đôi để cài            (macOS)
Mở AutoReel.command      nhấp đôi để mở app         (macOS)
Mở Chrome Shopee.command nhấp đôi để đăng nhập Shopee (macOS)
tools/              script đóng gói .dmg — chỉ máy phát triển
```

Ba file `.command` chỉ là cách nhấp đôi để chạy `install.sh`, `start.sh` và
`open-chrome.sh` — chúng không làm gì thêm. Máy Windows dùng `start.bat` và
`open-chrome.bat` như cũ.

Trong đây **không có** script đẩy image: việc đó chỉ có nghĩa trên máy phát
triển, và hai script ấy nằm trong kho mã nguồn — xem mục cuối file.

## Cần gì trước khi bắt đầu

- **Windows 10/11** hoặc **macOS** (Intel hay Apple Silicon đều được — xem mục
  *Hai loại chip* bên dưới).
- Còn khoảng **15 GB** trống (image + model).
- Kết nối mạng (lần đầu tải image và model: ZeroTTS ~900 MB, Whisper ~140 MB).
- Một điện thoại Android **nếu** dùng chức năng đăng bài lên Shopee Video.

## Cài đặt

**Windows:** cài **Git for Windows** (<https://git-scm.com/download/win>), rồi
nhấp phải trong thư mục này → **Open Git Bash here** → `./install.sh`.

**macOS** — bốn bước, theo đúng thứ tự:

1. **Nhấp đôi `AutoReel.dmg`** vừa tải về. macOS mở nó ra như một ổ đĩa, và một
   cửa sổ Finder hiện lên với thư mục `AutoReel` bên trong.
2. **Kéo thư mục `AutoReel` ra Desktop.** Rồi đóng cửa sổ `.dmg` lại (bấm nút
   đẩy ra cạnh tên ổ đĩa trong Finder).
3. **Gỡ chặn của macOS** — làm một lần, xem mục dưới.
4. Mở **`AutoReel.app`**. Giao diện hiện ra và tự làm mọi việc: kiểm tra máy, cài
   Docker, tải dữ liệu, kích hoạt bản quyền. Lần sau chỉ cần nhấp đôi.

> **Bước 2 không bỏ được.** File `.dmg` khi mở ra là ổ **chỉ đọc**. Chạy thẳng
> từ trong đó thì app không tạo được file `.env` hay thư mục `data`, và câu báo
> lỗi là "Read-only file system" — nghe như hỏng đĩa chứ không như "quên kéo
> thư mục ra". Ba file `.command` trong thư mục tự phát hiện việc này và nhắc
> bạn kéo ra, nhưng kéo ra từ đầu thì nhanh hơn.
>
> **Bạn không phải gõ gì trong Terminal để cài đặt.** Toàn bộ việc cài nằm trong
> cửa sổ của app. Chỉ có một dòng ở bước 3, và nó chỉ để macOS chịu mở app ra.
>
> `Cài đặt.command` và `Mở AutoReel.command` vẫn còn trong thư mục, nhưng giờ
> chúng chỉ **mở app**. Cách chính là mở `AutoReel.app`.

## Gỡ chặn của macOS (một lần)

Lần đầu mở, macOS sẽ nói một trong hai câu:

- *"Apple could not verify AutoReel is free of malware…"*
- *"AutoReel cannot be opened because the developer cannot be verified"*

**Cả hai đều bình thường.** App không có chứng chỉ Apple Developer (99 USD/năm),
nên Apple không xác nhận được ai viết nó. Không phải app hỏng.

**Cách 1 — Terminal (nhanh nhất, dùng được trên mọi bản macOS):**

Mở **Terminal**, gõ `xattr -dr com.apple.quarantine ` (nhớ dấu cách ở cuối), rồi
**kéo thư mục `AutoReel` vào cửa sổ Terminal** — nó tự điền đường dẫn — rồi Enter.
Xong. Từ đó mở app bình thường, và cả ba file `.command` cũng chạy được.

**Cách 2 — bằng giao diện:**

1. Nhấp đôi `AutoReel.app` → hiện thông báo → bấm **Done**
2. Mở **System Settings** → **Privacy & Security**
3. Kéo xuống mục **Security**
4. Có dòng *"AutoReel was blocked…"* → bấm **Open Anyway**
5. Nhập mật khẩu máy, rồi mở app

> **Nhấp phải → Mở không còn tác dụng** trên macOS 15 trở lên — Apple đã bỏ cách
> đó. Nếu bạn đọc ở đâu đó hướng dẫn nhấp phải, nó đã cũ.

Cách cũ, nếu bạn quen Terminal — mở **Terminal**, `cd` vào thư mục này rồi
`./install.sh`. Không cần cài gì trước: script dùng Homebrew nếu có, và tải
thẳng từ Google nếu không.

> Nếu Terminal báo `permission denied`: thư mục vừa được chép từ nơi khác tới
> (zip, USB) nên mất quyền chạy. Gõ `chmod +x *.sh` rồi chạy lại.

Script kiểm tra từng thứ, cài cái còn thiếu, rồi in bảng tổng kết: `✓` xong,
`!` cần để ý, `x` chưa xong. Chạy lại được nhiều lần. Muốn xem máy đang thiếu gì
mà **không** cài gì: `./install.sh check`.

Nó **không** tự đăng nhập Shopee và **không** ghép điện thoại — hai việc đó cần
người, xem dưới.

## Hai loại chip

Image được đẩy cho **cả `linux/amd64` và `linux/arm64`**, nên `docker pull` tự
lấy đúng bản cho máy:

| Máy | Bản được kéo | Ghi chú |
|---|---|---|
| Windows (Intel/AMD) | amd64 | chạy thẳng |
| Mac Intel | amd64 | chạy thẳng |
| Mac Apple Silicon (M1/M2/M3/M4) | arm64 | chạy thẳng, không giả lập |

`install.sh` in ra dòng `Image: linux/arm64 - đúng kiến trúc của máy này` (hoặc
cảnh báo nếu vì lý do gì đó phải chạy giả lập — khi đó whisper và bước render
chậm hơn nhiều lần).

## Sau khi cài: năm bước

### 1. Đăng nhập Shopee (để đọc link sản phẩm và đăng bài)

Mở **`open-chrome.bat`** (Windows: nhấp đôi) hoặc **`./open-chrome.sh`** (macOS),
đăng nhập Shopee trong cửa sổ hiện ra, rồi **để cửa sổ đó mở** trong lúc dùng
app.

Cửa sổ này dùng hồ sơ Chrome riêng (`.chrome-shopee` trong thư mục này) — trình
duyệt bạn vẫn dùng hằng ngày không bị đụng tới và không phải đóng. Phiên đăng
nhập nằm trong hồ sơ đó, nên lần sau chỉ cần mở lại là xong.

### 2. Nối điện thoại Android (chỉ khi đăng bài lên Shopee Video)

Trên điện thoại: bật **USB debugging** trong Tuỳ chọn nhà phát triển, cắm cáp,
và chấp nhận hộp thoại *"Cho phép gỡ lỗi USB"*.

Kiểm tra (đường dẫn adb nằm trong thư mục này — `adb.exe` trên Windows, `adb`
trên macOS):

```bash
./platform-tools/adb devices        # macOS
./platform-tools/adb.exe devices    # Windows (Git Bash)
```

Android 11 trở lên nối được qua Wi-Fi, không cần cáp — trên điện thoại mở
*Ghép thiết bị bằng mã*, rồi (đổi `adb` thành `adb.exe` nếu là Windows):

```bash
./platform-tools/adb pair 192.168.1.20:41234   # ip:cổng trong hộp thoại
./platform-tools/adb connect 192.168.1.20:37123 # cổng này KHÁC cổng pair
```

Trên macOS, adb nói chuyện với điện thoại **qua máy này**; container nối tới nó
qua `host.docker.internal:5037` — cùng cách Windows làm, nên không phải cấu hình
gì thêm.

### 3. Mở app

<http://localhost:31415> — hoặc nhấp đôi **`start.bat`**.

Máy nào đã có thứ khác chiếm cổng 31415 thì điền `SHORTGPT_PORT=31416` vào
`.env` rồi `docker compose up -d` — `start.bat` và `install.sh` đọc đúng cổng
đó.

### 4. Nhập mã kích hoạt (bản quyền)

Bạn được cấp một mã dạng `AR-XXXX-XXXX-XXXX-XXXX` khi mua phần mềm. Nhập nó một
lần:

1. Mở app → **Cấu hình** (mục cuối sidebar)
2. Kéo xuống cuối màn hình, tới mục **Bản quyền**
3. Dán mã vào ô **Mã kích hoạt** → bấm **Kích hoạt**

Xong. Mã được lưu trong `./data/database`, nên cập nhật hay khởi động lại đều
không phải nhập lại.

**Mã này gắn với máy.** Cài lại Windows hay đổi máy thì cần mã mới — liên hệ nơi
bán, họ gỡ máy cũ khỏi hệ thống rồi cấp lại.

#### Sau khi kích hoạt, phần mềm tự bắt buộc bản quyền

Đây là điều đáng biết trước: **từ lúc kích hoạt, app sẽ từ chối làm việc nếu
bản quyền hết hạn hoặc bị thu hồi.** Trước khi kích hoạt thì không — nên nếu bạn
chưa có mã, app vẫn chạy bình thường và bạn cứ dùng thử trước.

Khi bản quyền sắp hết hạn, mục **Bản quyền** trong Cấu hình sẽ hiện cảnh báo.
Gia hạn rồi bấm **Kiểm tra ngay** là xong, không cần cài lại gì.

> Máy cần kết nối mạng ít nhất một lần mỗi vài ngày để app kiểm tra bản quyền.
> Nếu mất mạng, app vẫn chạy tiếp trong **72 giờ**; quá đó thì cần có mạng lại.
> Đây là lý do app không dùng được trên máy hoàn toàn không có internet.
>
> Thu hồi và tạm khoá **không** chờ 72 giờ đó — chúng có hiệu lực ngay ở lần
> kiểm tra kế tiếp.

### 5. Kết nối Facebook (chỉ khi đăng bài lên Page)

Cần một app Meta của chính bạn và khoảng 10 phút. **Từng bước một, kèm ba lỗi
hay gặp: [`HUONG-DAN-FACEBOOK.md`](HUONG-DAN-FACEBOOK.md)** — mở file đó bằng
Notepad hoặc trình duyệt.

Tóm tắt: tạo app Meta → thêm Facebook Login → bật ba quyền
(`pages_show_list`, `pages_read_engagement`, `pages_manage_posts`) → khai
`https://autoreelvn.com/facebook/callback/` vào *Valid OAuth Redirect URIs* và
`autoreelvn.com` vào *App Domains* → dán App ID/App Secret vào màn **Cấu
hình** của app → bấm **Connect Facebook** và làm theo hướng dẫn trên màn hình.

**Không có tên miền riêng, hoặc luồng Connect bị Meta chặn?** Bỏ qua toàn bộ
phần địa chỉ quay về ở trên: lấy token ở Graph API Explorer rồi dán vào ô
*"Token để dán"* trên màn **Facebook** — xem mục *Cách khác: dán token* trong
file hướng dẫn. Đường này không cần tên miền, không cần `FB_REDIRECT_URI`, và
token Page lấy theo cách đó **không hết hạn** (khỏi phải nối lại sau 60 ngày).

Muốn bài đăng **công khai** (không chỉ mình bạn thấy) thì sau đó chuyển app
Meta sang **Live** — cũng nằm trong file hướng dẫn.

## Cập nhật

**`start.bat` / `./start.sh` tự làm việc này.** Mỗi lần khởi động, nó kiểm tra
một lượt xem có bản mới không — có thì tải về, không thì chạy tiếp. Bạn không
cần làm gì.

Mất mạng thì nó báo `! Không kiểm tra được bản mới` rồi **vẫn mở app** bằng bản
đang có trên máy. Nên mất mạng không chặn bạn làm việc.

Làm tay, khi muốn chắc chắn:

```bash
docker compose pull
docker compose up -d
```

Muốn ghim đúng một bản (để mọi máy khách hàng chạy giống nhau) thì điền vào
`.env`:

```
SHORTGPT_IMAGE=ghcr.io/linhdev/shortgpt:2026-10-12.2
MPT_IMAGE=ghcr.io/linhdev/moneyprinterturbo:2026-10-12.2
```

> **Vì sao `start` phải tự kiểm tra.** `docker compose up -d` một mình chỉ dùng
> image đã nằm sẵn trên máy. Một bản cài đã tải image về sẽ giữ nguyên bản đó
> **mãi mãi**, và bên bán đẩy bản mới lên cũng không tới được ai — không có gì
> trên máy khách chủ động đi lấy. Kiểm tra ở mỗi lần khởi động là chỗ duy nhất
> nó tự tới.

## Dữ liệu nằm ở đâu

Tất cả trong `./data`, không có gì nằm trong container — cập nhật hay xoá
container cũng không mất:

| Thư mục | Nội dung |
|---|---|
| `data/videos` | Video đã dựng |
| `data/database` | Database (kênh, lịch sử, asset) |
| `data/app-logs`, `data/logs` | Log của app, và bằng chứng từng lượt đăng Shopee |
| `data/cookies` | Cookie cho yt-dlp (youtube.txt / douyin.txt) |
| `data/input` | Phim dài để cắt highlight (thả file vào đây) |
| `data/models` | Model ZeroTTS, Whisper, bộ xoá logo |
| `data/mpt-data` | Cấu hình và kết quả của AutoReel Engine |

## Khi có trục trặc

| Hiện tượng | Xem gì |
|---|---|
| App không mở được | `docker compose logs --tail 100 shortgpt` |
| Nút Docker báo lỗi | Docker Desktop đã chạy chưa (biểu tượng dưới khay hệ thống) |
| Màn Shopee báo bị chặn / không đọc được link | Cửa sổ `open-chrome.bat` đã mở và đã đăng nhập chưa |
| Không thấy điện thoại | `./platform-tools/adb devices` (`adb.exe` trên Windows) — phải thấy trạng thái `device`, không phải `unauthorized` |
| Đăng bài Shopee thất bại | `data/logs/shopee/<mã batch>/<tên video>/` — có `log.txt`, ảnh chụp màn hình, `ui.xml`, `result.json` |
| Video tự động không chạy | `docker compose logs --tail 100 mpt-api` |
| Chức năng cần key báo lỗi | Mở `.env`, điền `OPENAI_API_KEY` / `PEXELS_API_KEY`, rồi `docker compose up -d` |

Chạy `./install.sh check` để có bảng tổng kết tình trạng hiện tại.

## Dành cho máy phát triển

### Đóng gói bộ cài Mac (.dmg)

```bash
./tools/build-dmg.sh 2026-10-12.2      # chỉ chạy được trên macOS
```

Trên Windows thì chạy workflow **Build macOS .dmg** trong tab Actions của repo
này — GitHub cho thuê một máy Mac thật để chạy đúng script đó. Điền version vào
ô nhập, bấm Run.

`.dmg` không chứa mã máy nào, chỉ có script và file compose, nên **một file dùng
được cho cả Mac Intel lẫn Apple Silicon**. Kiến trúc chỉ thành vấn đề ở image
Docker, và image có sẵn cả hai bản — `docker pull` tự lấy đúng bản.

Script tự loại `data/`, `.env`, `.chrome-shopee/`, `tools/`, `.github/`, `.git/`
và `dist/` ra khỏi bản đóng gói, rồi **từ chối đóng** nếu phát hiện `.env` hoặc
`data/` lọt vào. Workflow kiểm thêm ba thứ nữa sau khi tạo file: `.dmg` gắn vào
được, các script còn quyền chạy, và **không file nào có ký tự CR** — một script
bash có CRLF chết ngay ở dòng shebang và khách chỉ thấy cửa sổ Terminal loé lên
rồi tắt.

### Đẩy image

**Đẩy image là việc của kho mã nguồn, không phải của thư mục này** — hai script
đó nằm ở `tools/` trong kho (`tools/publish-images.sh` và
`tools/check-ghcr-push.sh`), vì máy khách hàng không có việc gì với chúng và
thư mục này cố ý không mang mã nguồn.

`tools/publish-images.sh` build hai image từ cây mã nguồn và đẩy lên ghcr **cho
cả hai kiến trúc** (amd64 + arm64), thành một manifest list dưới cùng một tag:

```bash
./tools/publish-images.sh 2026-10-04              # cả hai kiến trúc
./tools/publish-images.sh 2026-10-04 --amd64-only # chỉ amd64 (nhanh hơn nhiều)
```

Phần arm64 được build bằng QEMU ngay trên máy bạn, nên nó là phần chậm — hàng
chục phút. `tools/check-ghcr-push.sh` chạy trước để token thiếu quyền
`write:packages` không tốn cả buổi build mới lộ ra.

Nhớ đẩy lại mỗi lần sửa mã nguồn: image chỉ mới bằng đúng lúc nó được build, và
máy khách hàng chỉ thấy những gì đã đẩy lên.

Máy khách hàng chỉ cần `docker compose pull`. Lần đẩy đầu tiên, package trên
ghcr mặc định là **private** — vào GitHub → Packages → chọn package → *Package
settings* → *Danger Zone* → **Change visibility → Public**, nếu không muốn mỗi
máy khách phải `docker login`.

Kiểm tra một tag đã có đủ hai kiến trúc chưa:

```bash
docker buildx imagetools inspect ghcr.io/linhdev/shortgpt:latest
```
