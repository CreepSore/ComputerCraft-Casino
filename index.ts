import {EventEmitter} from "events";

import * as express from "express";
import * as path from "path";

import IExecutionContext, { IAppExecutionContext, IChildExecutionContext as IChildAppExecutionContext, ICliExecutionContext, ITestExecutionContext } from "@service/extensions/IExecutionContext";
import IExtension, { ExtensionMetadata } from "@service/extensions/IExtension";
import ConfigLoader from "@logic/config/ConfigLoader";
import Core from "@extensions/Core";
import CoreWeb from "../Core.Web";
import ScriptRepository from "./ScriptRepository";

class CustomComputercraftConfig {

}

export default class CustomComputercraft implements IExtension {
    static metadata: ExtensionMetadata = {
        name: "Custom.Computercraft",
        version: "1.0.0",
        description: "Computercraft Module",
        author: "ehdes",
        dependencies: [Core, CoreWeb],
    };

    metadata: ExtensionMetadata = CustomComputercraft.metadata;

    config: CustomComputercraftConfig = new CustomComputercraftConfig();
    events: EventEmitter = new EventEmitter();
    $: <T extends IExtension>(name: string|Function & { prototype: T }) => T;

    constructor() {
        this.config = this.loadConfig();
    }

    async start(executionContext: IExecutionContext): Promise<void> {
        this.checkConfig();
        this.$ = <T extends IExtension>(name: string|Function & { prototype: T }) => executionContext.extensionService.getExtension(name) as T;
        if(executionContext.contextType === "cli") {
            await this.startCli(executionContext);
            return;
        }
        else if(executionContext.contextType === "app") {
            await this.startMain(executionContext);
            return;
        }
        else if(executionContext.contextType === "child-app") {
            await this.startChildApp(executionContext);
            return;
        }
        else if(executionContext.contextType === "test") {
            await this.startTestApp(executionContext);
            return;
        }
    }

    async stop(): Promise<void> {

    }

    private async startCli(executionContext: ICliExecutionContext): Promise<void> {

    }

    private async startMain(executionContext: IAppExecutionContext): Promise<void> {
        const coreWeb = this.$(CoreWeb);
        const scriptRepostiory = new ScriptRepository();

        const middleware = scriptRepostiory.middleware("https://beta.ehdes.com/cc", path.resolve(this.metadata.extensionPath, "scripts"));

        coreWeb.app.get("/cc/script/:name/install", middleware);
        coreWeb.app.get("/cc/script/:name/install/:autorun", middleware);
        coreWeb.app.use("/cc/scripts", express.static(path.resolve(this.metadata.extensionPath, "scripts")));
    }

    private async startChildApp(executionContext: IChildAppExecutionContext): Promise<void> {

    }

    private async startTestApp(executionContext: ITestExecutionContext): Promise<void> {

    }

    private checkConfig(): void {
        if(!this.config) {
            throw new Error(`Config could not be found at [${this.generateConfigNames()[0]}]`);
        }
    }

    private loadConfig(createDefault: boolean = false): typeof this.config {
        const [configPath, templatePath] = this.generateConfigNames();
        return ConfigLoader.initConfigWithModel(
            configPath,
            templatePath,
            new CustomComputercraftConfig(),
            createDefault,
        );
    }

    private generateConfigNames(): string[] {
        return [
            ConfigLoader.createConfigPath(`${this.metadata.name}.json`),
            ConfigLoader.createTemplateConfigPath(`${this.metadata.name}.json`),
        ];
    }
}
