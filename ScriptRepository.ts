import * as fsp from "fs/promises";
import * as fs from "fs";
import * as path from "path";

import * as express from "express";
import LogBuilder from "../../src/service/logger/LogBuilder";

type ScriptEntry = {
    name: string;
    entrypoint: string;
    baseDirectory: string;
};

export default class ScriptRepository {
    scripts: Map<string, ScriptEntry> = new Map();

    addScriptEntry(script: ScriptEntry): this {
        this.scripts.set(script.name, script);
        return this;
    }

    middleware(baseUrl: string, scriptDir: string): express.RequestHandler {
        return async(req: express.Request<{name: string, autorun: "true"|"false"}>, res) => {
            const doAutorun = req.params.autorun ? req.params.autorun === "true" : true;

            this.scripts.clear();
            await this.loadScriptDirectory(scriptDir);

            const script = this.scripts.get(req.params.name);

            if(!script) {
                res.status(404).send("print('Script not found!')");
                return;
            }

            const installer = await this.createInstallerFile(script, baseUrl, doAutorun);

            res.header("Content-Type", "text/txt").status(200).send(installer);
        };
    }

    async createInstallerFile(script: ScriptEntry, baseUrl: string, doAutorun: boolean): Promise<string> {
        const files = await this.traverseDirectory(script.baseDirectory, `scripts/${script.name}`);

        return `-- Installer for "${script.name}"
${files.map(f => `shell.run("rm ${f}")`).join("\n")}

${files.map(f => `shell.run("wget ${baseUrl}/${f} ${f}")`).join("\n")}

${doAutorun ? `shell.run("clear")
shell.run("scripts/${script.name}/${script.entrypoint}")` : ""}
`.trim();
    }

    async traverseDirectory(dir: string, basePath: string): Promise<string[]> {
        const result: string[] = [];

        for(const file of await fsp.readdir(dir)) {
            const fullPath = `${dir}/${file}`;
            const relativePath = `${basePath}/${file}`;

            if((await fsp.stat(fullPath)).isDirectory()) {
                result.push(...await this.traverseDirectory(fullPath, relativePath));
            }
            else {
                result.push(relativePath);
            }
        }

        return result;
    }

    async loadScriptDirectory(dir: string): Promise<void> {
        for(const directory of await fsp.readdir(dir)) {
            const fullPath = `${dir}/${directory}`;

            if((await fsp.stat(fullPath)).isDirectory()) {
                if(fs.existsSync(path.resolve(fullPath, "metadata.json"))) {
                    const metadata = JSON.parse(await fsp.readFile(path.resolve(fullPath, "metadata.json"), "utf-8"));

                    const script = {
                        name: metadata.name,
                        entrypoint: metadata.entrypoint,
                        baseDirectory: fullPath,
                    };

                    this.addScriptEntry(script);

                    LogBuilder
                        .start()
                        .level(LogBuilder.LogLevel.INFO)
                        .info("Custom.Computercraft", "ScriptRepository")
                        .level("Added script")
                        .object("script", script)
                        .done();
                }
            }
        }
    }
}
