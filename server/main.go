package main

import (
	"log"
	"net/http"
	"os"
	"github.com/you/learning_search/handlers"
	"github.com/you/learning_search/services"

	"github.com/gorilla/mux"
	"github.com/rs/cors"
	"github.com/joho/godotenv"
)

func main() {
	// 加载 .env 文件
	godotenv.Load()

	// 初始化服务
	searchService := services.NewSearchService()
	handler := handlers.NewSearchHandler(searchService)

	// 设置路由
	r := mux.NewRouter()

	// API 路由
	api := r.PathPrefix("/api").Subrouter()
	api.HandleFunc("/search", handler.Search).Methods("POST")
	api.HandleFunc("/explain", handler.Explain).Methods("POST")
	api.HandleFunc("/explain-custom", handler.ExplainCustom).Methods("POST")
	api.HandleFunc("/generate-document", handler.GenerateDocument).Methods("POST")
	api.HandleFunc("/export", handler.Export).Methods("POST")

	// CORS 处理
	c := cors.New(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"GET", "POST", "OPTIONS"},
		AllowedHeaders:   []string{"*"},
		AllowCredentials: true,
	})

	handlerChain := c.Handler(r)

	// 获取端口配置，默认 8081
	port := os.Getenv("PORT")
	if port == "" {
		port = "8081"
	}
	listenAddr := ":" + port

	// 启动服务
	log.Printf("Server starting on %s...\n", listenAddr)
	log.Fatal(http.ListenAndServe(listenAddr, handlerChain))
}
