# CurrencyConverterAPI

A FastAPI service that converts amounts between Peruvian soles and US dollars, using live rates from the [Exchange Rates Data API](https://apilayer.com/marketplace/exchangerates_data-api).

The conversion itself is one HTTP call. The repository is about the shape around it: four layers with the dependency arrows pointing inward, so the rule that decides *what* a conversion means never touches the library that fetches it.

## The API

| Method | Path                      | Query parameters                        |
| ------ | ------------------------- | --------------------------------------- |
| `GET`  | `/api/v1/convertcurrency` | `amount`, `fromcurrency`, `tocurrency`  |

`fromcurrency` and `tocurrency` accept `PEN` or `USD`. The response carries a single `result` field.

```
GET /api/v1/convertcurrency?amount=100&fromcurrency=USD&tocurrency=PEN
{"result": 371.25}
```

Interactive documentation is at `/api/v1/docs`.

## How the code is organised

```
src/
├── presentation/         FastAPI app factory and the endpoint
├── business_logic/       Currency, the service, and the repository contract
├── data_access/          The contract's implementation and the HTTP client
└── dependency_injection/ Wiring and settings
```

`business_logic` declares `CurrencyConverterRepository` as an abstract base class and depends on nothing but itself. `data_access` implements that contract and owns every detail the provider imposes — the `apikey` header, the `from` and `to` parameter names, the response envelope. Swapping providers means writing one class in `data_access` and changing one line of wiring.

`dependency_injection` keeps that wiring in a single place rather than scattering `Depends` calls through the routes, so the composition of the application is readable top to bottom.

## Configuration

Two variables, in a `.env` file at the repository root:

```
EXCHANGE_RATES_DATA_API_KEY=your-apilayer-key
EXCHANGE_RATES_DATA_API_CURRENCY_CONVERSION_ENDPOINT=https://api.apilayer.com/exchangerates_data/convert
```

## Running it

Requires Python 3.10+ and [Poetry](https://python-poetry.org/).

```bash
poetry install
poetry run python src/main.py
```

The service listens on <http://localhost:8000>.

## Code quality

The project runs `ruff`, `ruff-format`, `mypy`, and `reorder-python-imports` through pre-commit, along with checks for private keys, merge conflicts, and oversized files.

```bash
poetry run poe format
```

A `no-commit-to-branch` hook guards `develop` against direct commits.

## License

MIT — see [LICENSE](LICENSE).
